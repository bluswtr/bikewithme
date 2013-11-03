module Mongo
  module Inviteable
    module History
      extend ActiveSupport::Concern

      included do |base|
        if base.include?(Mongo::Inviteable::Inviter)
          if defined?(Mongoid)
            base.field :invite_history, :type => Array, :default => []
          elsif defined?(MongoMapper)
            base.key :invite_history, :type => Array, :default => []
          end
        end

        if base.include?(Mongo::Inviteable::Invited)
          if defined?(Mongoid)
            base.field :invited_history, :type => Array, :default => []
          elsif defined?(MongoMapper)
            base.key :invited_history, :type => Array, :default => []
          end
        end
      end

      module ClassMethods
 #       def clear_history!
 #         self.all.each { |m| m.unset(:invite_history) }
 #         self.all.each { |m| m.unset(:invited_history) }
 #       end
      end

      def clear_history!
        clear_invite_history!
        clear_invited_histroy!
      end

      def clear_invite_history!
        self.update_attribute(:invite_history, []) if has_invite_history?
      end

      def clear_invited_histroy!
        self.update_attribute(:invited_history, []) if has_invited_history?
      end

      def ever_invite
        rebuild(self.invite_history) if has_invite_history?
      end

      def ever_invited
        rebuild(self.invited_history) if has_invited_history?
      end

      def ever_invite?(model)
        self.invite_history.include?(model.class.name + "_" + model.id.to_s) if has_invite_history?
      end

      def ever_invited?(model)
        self.invited_history.include?(model.class.name + "_" + model.id.to_s) if has_invited_history?
      end

      private
        def has_invite_history?
          self.respond_to? :invite_history
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