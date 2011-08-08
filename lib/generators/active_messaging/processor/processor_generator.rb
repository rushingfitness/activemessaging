module ActiveMessaging
  module Generators
    class ProcessorGenerator < Rails::Generators::NamedBase
      desc <<DESC
Description:
    Generates a stub ActiveMessaging Processor and associated test.
DESC

      check_class_collision :suffix => "Processor"
      check_class_collision :suffix => "ProcessorTest"

      def self.source_root
        @source_root ||= File.expand_path(File.join(File.dirname(__FILE__), 'templates'))
      end

      def generate_config
        template 'application.rb',  application_processor_path unless File.exists?(application_processor_path)
        template 'broker.yml', broker_path unless File.exists?(broker_path)
        template 'messaging.rb', messaging_path unless File.exists?(messaging_path)
      end

      def generate_poller
        template 'poller.rb', File.join('lib', "poller.rb")
        if defined?(JRUBY_VERSION)
          template 'jruby_poller',  File.join('scripts', "jruby_poller")
          chmod File.join('scripts', "jruby_poller"), 0755
        else
          template 'poller', File.join('scripts', "poller")
          chmod File.join('scripts', "poller"), 0755
        end
      end

      def generate_processor_class
        empty_directory processors_path
        template 'processor.rb', File.join(processors_path, class_path, "#{file_name}_processor.rb")
        template 'processor_test.rb', File.join('test/functional', class_path, "#{file_name}_processor_test.rb")
        add_destination(singular_name, class_name)
      end

      protected

      def processors_path
        File.join('app', 'processors')
      end

      def messaging_path
        File.join('config', 'messaging.rb')
      end

      def broker_path
        File.join('config','broker.yml')
      end

      def application_processor_path
        File.join(processors_path, 'application.rb')
      end

      def add_destination(destination_symbol, queue_name)
        destination_code = "s.destination :#{destination_symbol}, '/queue/#{queue_name}'"

        log :destination, destination_code
        sentinel = /ActiveMessaging::Gateway\.define do(?:\s*\|s\|)?\s*$/

        in_root do
          inject_into_file 'config/messaging.rb', "\n  #{destination_code}\n", { :after => sentinel, :verbose => true }
        end
      end
    end
  end
end
