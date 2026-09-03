package testsuite

import (
	"context"
	"strings"
	"testing"
	"time"

	"github.com/stretchr/testify/require"
	"github.com/stretchr/testify/suite"
	"go.opentelemetry.io/otel/baggage"

	"github.com/muun/libwallet/platform/observability/otel"
	"github.com/muun/libwallet/platform/observability/tracing"
	"github.com/muun/libwallet/platform/test/testenv"
)

// Run takes a test suite and runs all the tests attached to it.
// This function is meant to run integration tests.
func Run(t *testing.T, s suite.TestingSuite) {
	if testing.Short() {
		t.Skip("skipping integration test suite")
	}
	suite.Run(t, s)
}

// BaseIntegrationSuite is the base suite to be used for integration test suites.
// It contains logic to be applied to all integration tests.
// Embed this struct in a concrete suite struct instead of suite.Suite.
type BaseIntegrationSuite struct {
	suite.Suite

	// Overrides testify default so that all failed assertions stop the test execution.
	*require.Assertions

	// Ctx is the per-test context to be used during tests.
	// Carries test configuration.
	Ctx context.Context

	// otel is the otel.Setup that should be registered for each test.
	otel *otel.Setup
}

// SetupSuite is run automatically before all tests in the suite.
// If the concrete suite overrides this method, then it needs to be manually called.
func (s *BaseIntegrationSuite) SetupSuite() {
	s.Assertions = require.New(s.T())

	s.Ctx = s.T().Context()

	s.otel = s.setupOpenTelemetry(s.Ctx)
}

// SetupTest is automatically run before each test in the suite.
// If the concrete suite overrides this method, then it needs to be manually called.
func (s *BaseIntegrationSuite) SetupTest() {
	s.Assertions = require.New(s.T())

	s.Ctx = s.T().Context()

	s.Ctx = s.startTracing(s.Ctx)
}

// setupOpenTelemetry creates and saves a new otel.Setup to be used for each test.
func (s *BaseIntegrationSuite) setupOpenTelemetry(ctx context.Context) *otel.Setup {
	env, err := testenv.LoadEnvironmentIntoMap("local_vars.env")
	s.NoError(err)

	otelSetup, err := otel.NewSetup(ctx, otel.NewConfigFromMap(env))
	s.NoError(err)

	// The ctx in Shutdown is just used for timeouts. Give shutdown 10 seconds.
	s.T().Cleanup(func() {
		shutdownCtx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
		defer cancel()
		_ = otelSetup.Shutdown(shutdownCtx)
	})

	return otelSetup
}

// startTracing opens the per-test root span, adds common tags, and closes root span on cleanup.
func (s *BaseIntegrationSuite) startTracing(ctx context.Context) context.Context {
	ctx = tracing.WithOpenTelemetrySetup(ctx, s.otel)

	name := s.T().Name()

	var testSuite, testCase string
	if nameParts := strings.SplitN(name, "/", 2); len(nameParts) == 2 {
		testSuite = nameParts[0]
		testCase = nameParts[1]
	} else {
		testCase = name
	}

	if testSuite != "" {
		ctx = s.addPropagatedTag(ctx, "test_suite", testSuite)
	}
	if testCase != "" {
		ctx = s.addPropagatedTag(ctx, "test_case", testCase)
	}

	ctx, trace := tracing.StartWithoutSampling(ctx, name, true)
	s.T().Cleanup(func() { trace.Finish() })

	s.T().Cleanup(func() {
		status := "success"
		switch {
		case s.T().Failed():
			status = "failed"
		case s.T().Skipped():
			status = "skipped"
		}
		trace.AddTag("test_status", status)
	})

	return ctx
}

// addPropagatedTag adds a tag to the OTel baggage to be attached to all spans created.
func (s *BaseIntegrationSuite) addPropagatedTag(
	ctx context.Context,
	key, value string,
) context.Context {
	member, err := baggage.NewMemberRaw(key, value)
	s.NoError(err)

	bag, err := baggage.FromContext(ctx).SetMember(member)
	s.NoError(err)

	return baggage.ContextWithBaggage(ctx, bag)
}
