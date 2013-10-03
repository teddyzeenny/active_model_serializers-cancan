module ActiveModel
  class Serializer
    module CanCan
      module Helpers
        def current_ability
          ability = RequestStore.store["current_ability"]
          if !ability
            ability = Ability.new(options[:scope])
            RequestStore.store["current_ability"] = ability
          end
          ability
        end

        def can?(*args)
          current_ability.can? *args
        end

        def cannot?
          current_ability.cannot? *args
        end
      end
    end
  end
end

ActiveModel::Serializer.send :include, ActiveModel::Serializer::CanCan::Helpers
