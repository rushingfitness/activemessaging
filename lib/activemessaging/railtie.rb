require 'activemessaging'

module ActiveMessaging
  if defined? Rails::Railtie
    require 'rails'
    class Railtie < Rails::Railtie
      initializer 'activemessaging.initialize' do
        ActiveMessaging.load_activemessaging
        ActionDispatch::Callbacks.to_prepare :activemessaging do
          ActiveMessaging.reload_activemessaging
        end
      end
      rake_tasks do
        load "tasks/activemessaging.rake"
      end
    end
  end
end
