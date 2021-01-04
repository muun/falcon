Pod::Spec.new do |s|
  s.name             = 'core'
  s.version          = '0.1.0'
  s.summary          = "Muun iOS app core lib"

  s.homepage         = 'https://muun.com'
  s.author           = { 'Juan Pablo Civile' => 'champo@muun.com', 'Manu Herrera' => 'manu@muun.com' }
  s.source           = { :git => 'https://github.com/muun/muun.git', :tag => s.version.to_s }

  s.swift_version = '5'
  s.ios.deployment_target = '11.0'
  s.static_framework = true

  # Only deps for notifications extension
  s.dependency 'Firebase/Crashlytics', '7.1'
  s.dependency 'GoogleUtilities'

  s.subspec 'all' do |sp|
    sp.source_files = 'Classes/**/*'

    # Dependency injection
    sp.dependency 'Dip', '7.0.1'

    # Local DB
    sp.dependency 'GRDB.swift', '4.14.0'
    sp.dependency 'RxGRDB', '0.18.0'

    # React
    sp.dependency 'RxSwift', '5.0.1'
    sp.dependency 'RxBlocking', '5.0.1'

    # GoogleDrive
    sp.dependency 'GoogleSignIn', '5.0.2'
    sp.dependency 'GoogleAPIClientForREST/Drive', '1.5.1'

    sp.vendored_framework = 'Libwallet.framework'
  end

  s.subspec 'notifications' do |sp|
    sp.vendored_framework = 'Libwallet.framework'
  end

  s.test_spec 'Tests' do |ts|
    ts.source_files = 'Tests/**/*'
  end

  s.script_phases = [{ 
        :name => 'Swiftlint', 
        :script => 'cd "$PODS_TARGET_SRCROOT"; if which swiftlint >/dev/null; then swiftlint; else echo "warning: SwiftLint not installed, download from https://github.com/realm/SwiftLint"; fi',
        :execution_position => :before_compile 
    }, { 
        :name => 'Libwallet', 
        :script => 'cd "$(git rev-parse --show-toplevel)"; ./tools/libwallet-ios.sh',
        :execution_position => :before_compile 
    }]
end
