package otel

import (
	"os"

	"go.opentelemetry.io/otel/attribute"
)

const (
	defaultServiceName = "libwallet"
	defaultEndpoint    = "api.honeycomb.io:443"
)

// Config is the input NewSetup uses to set up OTel.
type Config struct {
	// ServiceName will be automatically included as an attribute in every exported span.
	ServiceName string

	// HoneycombAPIKey is the Honeycomb team key. An empty value disables Honeycomb export.
	HoneycombAPIKey string

	// HoneycombDataset is the Honeycomb Classic dataset to use. Optional.
	HoneycombDataset string

	// HoneycombEndpoint is the Honeycomb endpoint used.
	HoneycombEndpoint string

	// LogSpans toggles logging spans when they end.
	LogSpans bool

	// ExtraAttrs are additional tags to inject into all newly created spans.
	ExtraAttrs []attribute.KeyValue
}

// newConfig builds a Config from the environment:
//
//	ServiceName: "libwallet"
//	APIKey: env["HONEYCOMB_KEY"]
//	Dataset: env["ENV"]
//	Endpoint: env["HONEYCOMB_ENDPOINT"] || "api.honeycomb.io:443"
//	LogSpans: env["CI"] != "true" -> Turn off logs on CI.
//	ExtraAttrs["pod"]: env["HOSTNAME"]
//	ExtraAttrs["variant"]: env["VARIANT"]
//	ExtraAttrs["ci_run_id"]: env["CI_RUN_ID"]
//	ExtraAttrs["git_branch"]: env["GIT_BRANCH"]
func newConfig(env envSupplier) Config {
	return Config{
		ServiceName:       defaultServiceName,
		HoneycombAPIKey:   env.getStringEnv("HONEYCOMB_KEY", ""),
		HoneycombDataset:  env.getStringEnv("ENV", ""),
		HoneycombEndpoint: env.getStringEnv("HONEYCOMB_ENDPOINT", defaultEndpoint),
		LogSpans:          env.getStringEnv("CI", "") != "true",
		ExtraAttrs: buildExtraAttrs(env, map[string]string{
			"pod":        "HOSTNAME",
			"variant":    "VARIANT",
			"ci_run_id":  "CI_RUN_ID",
			"git_branch": "GIT_BRANCH",
		}),
	}
}

// NewConfigFromEnv builds a Config from the OS environment.
func NewConfigFromEnv() Config {
	return newConfig(osEnvSupplier{})
}

// NewConfigFromMap builds a Config from the environment values provided in a map.
func NewConfigFromMap(values map[string]string) Config {
	return newConfig(mapEnvSupplier(values))
}

// buildExtraAttrs reads each (attribute name, env var name) pair and emits an attribute
// for each env var set.
func buildExtraAttrs(env envSupplier, extraAttrs map[string]string) []attribute.KeyValue {
	attrs := make([]attribute.KeyValue, 0, len(extraAttrs))

	for attrKey, envKey := range extraAttrs {
		if attrValue := env.getStringEnv(envKey, ""); attrValue != "" {
			attrs = append(attrs, attribute.String(attrKey, attrValue))
		}
	}

	return attrs
}

// envSupplier abstracts over different ways to access environment values.
type envSupplier interface {
	// getStringEnv returns env[key] when present, otherwise fallback.
	getStringEnv(key, fallback string) string
}

// mapEnvSupplier accesses the environment values present in a map.
type mapEnvSupplier map[string]string

func (env mapEnvSupplier) getStringEnv(key, fallback string) string {
	if value, ok := env[key]; ok {
		return value
	}
	return fallback
}

// osEnvSupplier accesses the environment variables set at the OS level.
type osEnvSupplier struct{}

func (osEnvSupplier) getStringEnv(key, fallback string) string {
	if value, ok := os.LookupEnv(key); ok {
		return value
	}
	return fallback
}
