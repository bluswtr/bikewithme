module Mongo
  module Invitable
    module History
      extend ActiveSupport::Concern

      included do |base|
        if base.include?(Mongo::Invitable::Inviter)
          if defined?(Mongoid)
            base.field :invit_history, :type => Array, :default => []
          elsif defined?(MongoMapper)
            base.key :invit_history, :type => Array, :default => []
          end
        end

        if base.include?(Mongo::Invitable::Invited)
          if defined?(Mongoid)
            base.field :invited_history, :type => Array, :default => []
          elsif defined?(MongoMapper)
            base.key :invited_history, :type => Array, :default => []
          end
        end
      end

      module ClassMethods
 #       def clear_history!
 #         self.all.each { |m| m.unset(:invit_history) }
 #         self.all.each { |m| m.unset(:invited_history) }
 #       end
      end

      def clear_history!
        clear_invit_history!
        clear_invited_histroy!
      end

      def clear_invit_history!
        self.update_attribute(:invit_history, []) if has_invit_history?
      end

      def clear_invited_histroy!
        self.update_attribute(:invited_history, []) if has_invited_history?
      end

      def ever_invit
        rebuild(self.invit_history) if has_invit_history?
      end

      def ever_invited
        rebuild(self.invited_history) if has_invited_history?
      end

      def ever_invit?(model)
        self.invit_history.include?(model.class.name + "_" + model.id.to_s) if has_invit_history?
      end

      def ever_invited?(model)
        self.invited_history.include?(model.class.name + "_" + model.id.to_s) if has_invited_history?
      end

      private
        def has_invit_history?
          self.respond_to? :invit_history
        end

        def has_invited_history?
          self.respond_to? :invited_history
        end

        def rebuild(ary)
          ary.group_by { |x| x.split("_").first }.
              inject([]) { |n,(k,v)| n += k.constantize.
              find(v.map { |x| x.split("_").last}) }
        end
    end
  end
end