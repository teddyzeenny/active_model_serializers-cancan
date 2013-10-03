module ActiveModel
  class Serializer
    class Association #:nodoc:

      def authorize?
        RequestStore.store["authorize"] != false && options[:authorize] != false
      end

      class HasMany #:nodoc:
        def serializables_with_cancan
          return serializables_without_cancan unless authorize?
          yes = false
          object.each do |item|
            yes = find_serializable(item).can?(:read, item)
            break
          end
          return serializables_without_cancan if yes
          return []
        end
        alias_method_chain :serializables, :cancan

        def serialize_ids_with_cancan
          return serialize_ids_without_cancan unless authorize?
          yes = false
          object.each do |item|
            yes = find_serializable(item).can?(:read, item)
            break
          end
          return serialize_ids_without_cancan if yes
          return []
        end
        alias_method_chain :serialize_ids, :cancan

        def serialize_with_cancan
          return serialize_without_cancan unless authorize?
          object.select {|item| find_serializable(item).can?(:read, item) }.map do |item|
            find_serializable(item).serializable_hash
          end
        end
        alias_method_chain :serialize, :cancan

      end

      class HasOne #:nodoc:
        def serializables_with_cancan
          serializer = find_serializable(object)
          return [] unless !authorize? || serializer && serializer.can?(:read, object)
          serializables_without_cancan
        end
        alias_method_chain :serializables, :cancan

        def serialize_ids_with_cancan
          serializer = find_serializable(object)
          return nil unless !authorize? || serializer && serializer.can?(:read, object)
          serialize_ids_without_cancan
        end
        alias_method_chain :serialize_ids, :cancan

        def serialize_with_cancan
          serializer = find_serializable(object)
          return nil unless !authorize? || serializer && serializer.can?(:read, object)
          serialize_without_cancan
        end
        alias_method_chain :serialize, :cancan

      end
    end
  end
end
