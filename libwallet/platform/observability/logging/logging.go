// Package logging is libwallet's slog facade.
// Loggers travel and are configured through context.
package logging

import (
	"context"
	"log/slog"
)

type ctxKey struct{}

// WithLogger returns a new context with the given logger stored in it.
func WithLogger(ctx context.Context, logger *slog.Logger) context.Context {
	return context.WithValue(ctx, ctxKey{}, logger)
}

// Logger returns the logger on ctx, or slog.Default when ctx has none.
func Logger(ctx context.Context) *slog.Logger {
	if logger, ok := ctx.Value(ctxKey{}).(*slog.Logger); ok && logger != nil {
		return logger
	}
	return slog.Default()
}

// With returns a context whose logger has the given attributes added.
func With(ctx context.Context, args ...any) context.Context {
	return WithLogger(ctx, Logger(ctx).With(args...))
}

// WithGroup returns a context whose logger is grouped under name.
func WithGroup(ctx context.Context, name string) context.Context {
	return WithLogger(ctx, Logger(ctx).WithGroup(name))
}

// Debug logs at DebugLevel using the logger from ctx.
func Debug(ctx context.Context, msg string, args ...any) {
	Logger(ctx).DebugContext(ctx, msg, args...)
}

// Info logs at InfoLevel using the logger from ctx.
func Info(ctx context.Context, msg string, args ...any) {
	Logger(ctx).InfoContext(ctx, msg, args...)
}

// Warn logs at WarnLevel using the logger from ctx.
func Warn(ctx context.Context, msg string, args ...any) {
	Logger(ctx).WarnContext(ctx, msg, args...)
}

// Error logs at ErrorLevel using the logger from ctx.
func Error(ctx context.Context, msg string, args ...any) {
	Logger(ctx).ErrorContext(ctx, msg, args...)
}
