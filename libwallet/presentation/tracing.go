package presentation

import (
	"context"
	"time"

	"go.opentelemetry.io/otel/baggage"
	"google.golang.org/grpc/status"

	"github.com/muun/libwallet/platform/observability/logging"
	"github.com/muun/libwallet/platform/observability/otel"
	"github.com/muun/libwallet/platform/observability/tracing"
)

// tracingInterceptorHandler creates the requests' tracing root span, adds common tags, and logs the
// request result.
// OpenTelemetry is configured for the request only if an otel.Setup is provided.
func tracingInterceptorHandler(
	ctx context.Context,
	otelSetup *otel.Setup,
	method string,
	handler func(ctx context.Context) error,
) error {
	if otelSetup == nil {
		return handler(ctx)
	}

	ctx = tracing.WithOpenTelemetrySetup(ctx, otelSetup)

	name := otelSetup.ServiceName + " " + method
	ctx, err := addPropagatedTag(ctx, "execution_unit", "request: "+name)
	if err != nil {
		logging.Error(ctx, "Failed to add execution_unit propagated tag",
			"method", method,
			"error", err,
		)
	}

	ctx, trace := tracing.StartWithoutSampling(ctx, name, true)
	defer trace.Finish()

	tracing.AddTag(ctx, "method", method)

	startTime := time.Now()
	err = handler(ctx)
	duration := time.Since(startTime)

	if err != nil {
		trace.RecordErrorInline(err)
	}

	tracing.Current(ctx).
		AddTag("duration_ms", duration.Milliseconds()).
		AddTag("status_code", status.Code(err).String())

	return err
}

// addPropagatedTag adds a tag to the OTel baggage to be attached to all spans created.
func addPropagatedTag(ctx context.Context, key, value string) (context.Context, error) {
	member, err := baggage.NewMemberRaw(key, value)
	if err != nil {
		return ctx, err
	}

	bag, err := baggage.FromContext(ctx).SetMember(member)
	if err != nil {
		return ctx, err
	}

	return baggage.ContextWithBaggage(ctx, bag), nil
}
