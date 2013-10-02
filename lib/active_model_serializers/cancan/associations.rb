module ActiveModel
  class Serializer
    class Association #:nodoc:

      def authorize?
        options[:authorize] != false
      end

      class HasMany #:nodoc:
        def serializables_with_cancan
          return serializables_without_cancan unless authorize?
          object.select {|item| find_serializable(item).can?(:read, item) }.map do |item|
            find_serializable(item)
          end
        end
        alias_method_chain :serializables, :cancan

        def serialize_ids_with_cancan
          return serialize_ids_without_cancan unless authorize?
          object.select {|item| find_serializable(item).can?(:read, item) }.map do |item|
            serializer = find_serializable(item)
            if serializer.respond_to?(embed_key)
              serializer.send(embed_key)
            else
              item.read_attribute_for_serialization(embed_key)
            end
          end
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
