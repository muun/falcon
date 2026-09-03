package presentation

import (
	"fmt"
	"strings"
	"testing"

	"github.com/go-errors/errors"
	"github.com/stretchr/testify/require"
	"google.golang.org/grpc/status"
	"google.golang.org/protobuf/proto"

	apierrors "github.com/muun/libwallet/errors"
	"github.com/muun/libwallet/presentation/api"
)

func TestFormatStackFrameFunction(t *testing.T) {
	cases := []struct {
		name string
		in   string
		want string
	}{
		{name: "empty", in: "", want: ""},
		{name: "plain function", in: "MyFunc", want: "MyFunc"},
		{name: "pointer method", in: "(*T).Method", want: "(*T).Method"},
		{name: "value method", in: "T.ValMethod", want: "T.ValMethod"},
		{name: "single closure", in: "(*T).Method.func1", want: "(*T).Method.func1"},
		{
			name: "triple-nested closure in method",
			in:   "(*T).Method.func1.1.1",
			want: "(*T).Method.func1.func1.func1",
		},
		{
			name: "generic with nested closure",
			in:   "Foo[...].func1.1",
			want: "Foo[...].func1.func1",
		},
		{
			name: "generic method with nested closure",
			in:   "(*G[...]).GenMethod.func1.1",
			want: "(*G[...]).GenMethod.func1.func1",
		},
		{name: "pkg-level var init closure", in: "init.func1", want: "init.func1"},
		{
			name: "nested closure in pkg-level init",
			in:   "init.func1.1",
			want: "init.func1.func1",
		},
		{name: "numbered init only", in: "init.0", want: "init"},
		{name: "numbered init with closure", in: "init.0.func1", want: "init.func1"},
		{
			name: "numbered init with nested closure",
			in:   "init.0.func1.1",
			want: "init.func1.func1",
		},
	}

	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			require.Equal(t, tc.want, formatStackFrameFunction(tc.in))
		})
	}
}

func TestBuildErrorStackTrace(t *testing.T) {
	t.Run("nil error produces nil node", func(t *testing.T) {
		assertStackTrace(t, buildErrorStackTrace(nil), nil)
	})

	t.Run("error without stack produces nil node", func(t *testing.T) {
		err := fmt.Errorf("plain") //nolint:forbidigo // no stack
		assertStackTrace(t, buildErrorStackTrace(err), nil)
	})

	t.Run("multi-level wrap chain preserves each level", func(t *testing.T) {
		inner := errors.New("inner")
		middle := errors.Errorf("middle: %w", inner)
		outer := errors.Errorf("outer: %w", middle)

		assertStackTrace(t, buildErrorStackTrace(outer), &expectedNode{
			msgPrefix: "outer:",
			hasFrames: true,
			cause: &expectedNode{
				msgPrefix: "middle:",
				hasFrames: true,
				cause: &expectedNode{
					msgPrefix: "inner",
					hasFrames: true,
				},
			},
		})
	})

	t.Run("errors.Join at top fans out to siblings", func(t *testing.T) {
		a := errors.New("a")
		b := errors.New("b")

		assertStackTrace(t, buildErrorStackTrace(errors.Join(a, b)), &expectedNode{
			hasFrames: false,
			siblings: []*expectedNode{
				{msgPrefix: "a", hasFrames: true},
				{msgPrefix: "b", hasFrames: true},
			},
		})
	})

	t.Run("join with a single stack child collapses to a cause", func(t *testing.T) {
		withStack := errors.New("with stack")
		noStack := fmt.Errorf("no stack") //nolint:forbidigo // no stack

		// Only one child has a stack, so it becomes the cause rather than a sibling.
		// The root node keeps the join's full message.
		assertStackTrace(t, buildErrorStackTrace(errors.Join(withStack, noStack)), &expectedNode{
			msgPrefix: "with stack\nno stack",
			hasFrames: true,
		})
	})

	t.Run("wrap of join: outer carries stack, cause carries siblings", func(t *testing.T) {
		a := errors.New("a")
		b := errors.New("b")
		outer := errors.Errorf("outer: %w", errors.Join(a, b))

		assertStackTrace(t, buildErrorStackTrace(outer), &expectedNode{
			msgPrefix: "outer:",
			hasFrames: true,
			cause: &expectedNode{
				hasFrames: false,
				siblings: []*expectedNode{
					{msgPrefix: "a", hasFrames: true},
					{msgPrefix: "b", hasFrames: true},
				},
			},
		})
	})

	t.Run("nested join inside a sibling preserves grouping", func(t *testing.T) {
		a := errors.New("a")
		b := errors.New("b")
		c := errors.New("c")

		assertStackTrace(t, buildErrorStackTrace(errors.Join(a, errors.Join(b, c))), &expectedNode{
			hasFrames: false,
			siblings: []*expectedNode{
				{msgPrefix: "a", hasFrames: true},
				{
					hasFrames: false,
					siblings: []*expectedNode{
						{msgPrefix: "b", hasFrames: true},
						{msgPrefix: "c", hasFrames: true},
					},
				},
			},
		})
	})

	t.Run("no-stack wrap at the top keeps the full message", func(t *testing.T) {
		inner := errors.New("inner")
		outer := fmt.Errorf("outer: %w", inner) //nolint:forbidigo // no stack

		// The no-stack outer wrap is filtered, but its message survives in the root node.
		assertStackTrace(t, buildErrorStackTrace(outer), &expectedNode{
			msgPrefix: "outer: inner",
			hasFrames: true,
		})
	})

	t.Run("no-stack wrap above a join keeps the full message", func(t *testing.T) {
		a := errors.New("a")
		b := errors.New("b")
		outer := fmt.Errorf("outer: %w", errors.Join(a, b)) //nolint:forbidigo // no stack

		assertStackTrace(t, buildErrorStackTrace(outer), &expectedNode{
			msgPrefix: "outer: a\nb",
			hasFrames: false,
			siblings: []*expectedNode{
				{msgPrefix: "a", hasFrames: true},
				{msgPrefix: "b", hasFrames: true},
			},
		})
	})

	t.Run("no-stack wrap is collapsed", func(t *testing.T) {
		inner := errors.New("inner")
		passthrough := fmt.Errorf("passthrough: %w", inner) //nolint:forbidigo // no stack
		outer := errors.Errorf("outer: %w", passthrough)

		// Outer has stack; its cause skips the no-stack passthrough and links directly to inner.
		assertStackTrace(t, buildErrorStackTrace(outer), &expectedNode{
			msgPrefix: "outer:",
			hasFrames: true,
			cause: &expectedNode{
				msgPrefix: "inner",
				hasFrames: true,
			},
		})
	})
}

// testErrorDetailBudget is a fixed budget so truncation tests are deterministic regardless of
// the platform-dependent maxErrorDetailSize.
const testErrorDetailBudget = 16 * 1024

func TestCapErrorDetailSize(t *testing.T) {
	t.Run("detail within budget is untouched", func(t *testing.T) {
		detail := syntheticErrorDetail(syntheticStackTrace(2, 10))
		original := proto.Clone(detail).(*api.ErrorDetail)

		capErrorDetailSize(detail, testErrorDetailBudget)

		require.True(t, proto.Equal(original, detail))
	})

	t.Run("over-budget detail keeps a stack trace centered on the error site", func(t *testing.T) {
		detail := syntheticErrorDetail(syntheticStackTrace(4, 50))
		requireOverBudget(t, detail)

		capErrorDetailSize(detail, testErrorDetailBudget)

		require.LessOrEqual(t, proto.Size(detail), testErrorDetailBudget)
		require.NotNil(t, detail.GetStackTrace())

		var innermost *api.ErrorStackTrace
		for node := detail.GetStackTrace(); node != nil; node = node.GetCause() {
			// The frames closest to the error site must survive truncation.
			require.Equal(t, "errorSite", node.GetFrames()[0].GetFunction())
			innermost = node
		}
		// The innermost stack points at the origin of the error: it is never degraded.
		require.Len(t, innermost.GetFrames(), 50)

		assertErrorIdentityUntouched(t, detail)
	})

	t.Run("each joined error branch keeps its error site", func(t *testing.T) {
		stackTrace := syntheticStackTrace(1, 50)
		stackTrace.SetCause(api.ErrorStackTrace_builder{
			Message: "joined error",
			Siblings: []*api.ErrorStackTrace{
				syntheticStackTrace(2, 50),
				syntheticStackTrace(2, 50),
			},
		}.Build())
		detail := syntheticErrorDetail(stackTrace)
		requireOverBudget(t, detail)

		capErrorDetailSize(detail, testErrorDetailBudget)

		require.LessOrEqual(t, proto.Size(detail), testErrorDetailBudget)
		siblings := detail.GetStackTrace().GetCause().GetSiblings()
		require.Len(t, siblings, 2)
		for i, sibling := range siblings {
			require.Less(t, len(sibling.GetFrames()), 50, "sibling %d outer frames", i)
			require.Equal(t, "errorSite", sibling.GetFrames()[0].GetFunction(), "sibling %d", i)
			require.Len(t, sibling.GetCause().GetFrames(), 50, "sibling %d innermost frames", i)
		}
	})

	t.Run("over-budget single-node tree drops its stack trace", func(t *testing.T) {
		// The only node is also the innermost one, so frame truncation never degrades it and
		// the whole trace is dropped instead.
		detail := syntheticErrorDetail(syntheticStackTrace(1, 200))
		requireOverBudget(t, detail)

		capErrorDetailSize(detail, testErrorDetailBudget)

		require.LessOrEqual(t, proto.Size(detail), testErrorDetailBudget)
		require.Nil(t, detail.GetStackTrace())
		assertErrorIdentityUntouched(t, detail)
	})

	t.Run("stack trace dropped when frame truncation is not enough", func(t *testing.T) {
		// Frames per node already at the truncated size, so truncation cannot reclaim anything.
		detail := syntheticErrorDetail(syntheticStackTrace(50, 5))
		requireOverBudget(t, detail)

		capErrorDetailSize(detail, testErrorDetailBudget)

		require.LessOrEqual(t, proto.Size(detail), testErrorDetailBudget)
		require.Nil(t, detail.GetStackTrace())
		assertErrorIdentityUntouched(t, detail)
	})
}

func TestNewGrpcErrorDetailFitsTrailerBudget(t *testing.T) {
	if maxErrorDetailSize > 64*1024*1024 {
		t.Skip("maxErrorDetailSize is too big on this platform for this test to make sense")
	}

	hugeErr := deeplyWrappedError(120)
	require.Greater(t, proto.Size(buildErrorStackTrace(hugeErr)), maxErrorDetailSize,
		"uncapped stack trace must exceed the budget for this test to be meaningful")

	grpcErrors := map[string]error{
		"NewGrpcError": NewGrpcError(hugeErr),
		"NewGrpcErrorFromCodeAndErr": NewGrpcErrorFromCodeAndErr(
			apierrors.ErrorCodes.ErrUnknown,
			hugeErr,
		),
	}
	for name, grpcErr := range grpcErrors {
		t.Run(name, func(t *testing.T) {
			detail := getErrorDetail(t, status.Convert(grpcErr))

			require.LessOrEqual(t, proto.Size(detail), maxErrorDetailSize)
			// The full message chain survives capping, down to the innermost error.
			require.Contains(t, detail.GetDeveloperMessage(), "boom")
		})
	}
}

// requireOverBudget guards that a synthetic detail actually exercises truncation.
func requireOverBudget(t *testing.T, detail *api.ErrorDetail) {
	t.Helper()

	require.Greater(t, proto.Size(detail), testErrorDetailBudget,
		"synthetic detail must start over budget for this test to be meaningful")
}

// syntheticErrorDetail builds an ErrorDetail whose identity fields match
// assertErrorIdentityUntouched.
func syntheticErrorDetail(stackTrace *api.ErrorStackTrace) *api.ErrorDetail {
	return api.ErrorDetail_builder{
		Message:          "message",
		DeveloperMessage: "developer message",
		Code:             42,
		StackTrace:       stackTrace,
	}.Build()
}

// assertErrorIdentityUntouched checks that the fields identifying the error survived capping.
func assertErrorIdentityUntouched(t *testing.T, detail *api.ErrorDetail) {
	t.Helper()

	require.Equal(t, "message", detail.GetMessage())
	require.Equal(t, "developer message", detail.GetDeveloperMessage())
	require.Equal(t, int64(42), detail.GetCode())
}

// deeplyWrappedError creates an error at the given stack depth, wrapping it every 20 levels.
func deeplyWrappedError(depth int) error {
	if depth == 0 {
		return errors.New("boom")
	}

	err := deeplyWrappedError(depth - 1)
	if depth%20 == 0 {
		err = errors.Errorf("wrap at depth %d: %w", depth, err)
	}
	return err
}

// syntheticStackTrace builds a linear error tree with realistically sized frames. The first
// frame of every node is marked as "errorSite".
func syntheticStackTrace(nodes int, framesPerNode int) *api.ErrorStackTrace {
	var result *api.ErrorStackTrace
	for range nodes {
		frames := make([]*api.StackFrame, 0, framesPerNode)
		frames = append(frames, syntheticStackFrame("errorSite"))
		for i := 1; i < framesPerNode; i++ {
			frames = append(frames, syntheticStackFrame(fmt.Sprintf("caller%d", i)))
		}
		result = api.ErrorStackTrace_builder{
			Message: "some wrapped error message",
			Frames:  frames,
			Cause:   result,
		}.Build()
	}
	return result
}

func syntheticStackFrame(function string) *api.StackFrame {
	return api.StackFrame_builder{
		File:     "/Users/builder/project/libwallet/presentation/wallet_server.go",
		Line:     123,
		Function: function,
		Package:  "github.com/muun/libwallet/presentation",
	}.Build()
}

type expectedNode struct {
	msgPrefix string
	hasFrames bool
	cause     *expectedNode
	siblings  []*expectedNode
}

func assertStackTrace(t *testing.T, got *api.ErrorStackTrace, want *expectedNode) {
	t.Helper()

	if want == nil {
		require.Nil(t, got)
		return
	}
	require.NotNil(t, got, "want node %q", want.msgPrefix)

	require.True(t, strings.HasPrefix(got.GetMessage(), want.msgPrefix),
		"want message prefix %q, got %q", want.msgPrefix, got.GetMessage())

	if want.hasFrames {
		require.NotEmpty(t, got.GetFrames(), "want stack frames on %q", want.msgPrefix)
	} else {
		require.Empty(t, got.GetFrames(), "want no stack frames on %q", want.msgPrefix)
	}

	require.Len(t, got.GetSiblings(), len(want.siblings), "siblings on %q", want.msgPrefix)
	for i, wantSibling := range want.siblings {
		assertStackTrace(t, got.GetSiblings()[i], wantSibling)
	}

	assertStackTrace(t, got.GetCause(), want.cause)
}
