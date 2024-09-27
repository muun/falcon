package libwallet

import (
	"runtime/debug"
)

// Listener is an interface implemented by the apps to receive notifications
// of data changes from the libwallet code. Each change is reported with a
// string tag identifying the type of change.
type Listener interface {
	OnDataChanged(tag string)
}

// BackendActivatedFeatureStatusProvider is an interface implemented by the
// apps to provide us with information about the state of some backend side
// feature flags until we can implement a libwallet-side solution for this.
type BackendActivatedFeatureStatusProvider interface {
	IsBackendFlagEnabled(flag string) bool
}

// Config defines the global libwallet configuration.
type Config struct {
	DataDir               string
	Listener              Listener
	FeatureStatusProvider BackendActivatedFeatureStatusProvider
}

var Cfg *Config

// Init configures the libwallet
func Init(c *Config) {
	debug.SetTraceback("crash")
	Cfg = c
}
