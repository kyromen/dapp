module Dapp
  module Build
    module Stage
      # Source1Dependencies
      class Source1Dependencies < SourceDependenciesBase
        def initialize(application, next_stage)
          @prev_stage = Source1Archive.new(application, self)
          super
        end

        def signature
          hashsum [super, install_dependencies_files_checksum, *application.builder.install_checksum]
        end

        private

        def install_dependencies_files_checksum
          @install_dependencies_files_checksum ||= dependencies_files_checksum(application.config._install_dependencies)
        end
      end # Source1Dependencies
    end # Stage
  end # Build
end # Dapp