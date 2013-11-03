module Mongo
  module Inviteable
    module Invited
      extend ActiveSupport::Concern

      included do |base|
        if defined?(Mongoid)
          base.has_many :inviters, :class_name => "Invite", :as => :inviteable, :dependent => :destroy
        elsif defined?(MongoMapper)
          base.many :inviters, :class_name => "Invite", :as => :inviteable, :dependent => :destroy
        end
      end

      module ClassMethods

        # get certain model's invitees of this type
        #
        # Example:
        #   >> @jim = User.new
        #   >> @ruby = Group.new
        #   >> @jim.save
        #   >> @ruby.save
        #
        #   >> @jim.invite(@ruby)
        #   >> User.invitees_of(@jim)
        #   => [@ruby]
        #
        #   Arguments:
        #     model: instance of some inviteable model

        def invitees_of(model)
          model.invitees_by_type(self.name)
        end

        # 4 methods in this function
        #
        # Example:
        #   >> Group.with_max_inviters
        #   => [@ruby]
        #   >> Group.with_max_inviters_by_type('user')
        #   => [@ruby]

        ["max", "min"].each do |s|
          define_method(:"with_#{s}_inviters") do
            invite_array = self.all.to_a.sort! { |a, b| a.inviters_count <=> b.inviters_count }
            num = invite_array[-1].inviters_count
            invite_array.select { |c| c.inviters_count == num }
          end

          define_method(:"with_#{s}_inviters_by_type") do |*args|
            invite_array = self.all.to_a.sort! { |a, b| a.inviters_count_by_type(args[0]) <=> b.inviters_count_by_type(args[0]) }
            num = invite_array[-1].inviters_count_by_type(args[0])
            invite_array.select { |c| c.inviters_count_by_type(args[0]) == num }
          end
        end

        #def method_missing(name, *args)
        #  if name.to_s =~ /^with_(max|min)_inviters$/i
        #    invite_array = self.all.to_a.sort! { |a, b| a.inviters_count <=> b.inviters_count }
        #    if $1 == "max"
        #      max = invite_array[-1].inviters_count
        #      invite_array.select { |c| c.inviters_count == max }
        #    elsif $1 == "min"
        #      min = invite_array[0].inviters_count
        #      invite_array.select { |c| c.inviters_count == min }
        #    end
        #  elsif name.to_s =~ /^with_(max|min)_inviters_by_type$/i
        #    invite_array = self.all.to_a.sort! { |a, b| a.inviters_count_by_type(args[0]) <=> b.inviters_count_by_type(args[0]) }
        #    if $1 == "max"
        #      max = invite_array[-1].inviters_count_by_type(args[0])
        #      invite_array.select { |c| c.inviters_count_by_type(args[0]) == max }
        #    elsif $1 == "min"
        #      min = invite_array[0].inviters_count
        #      invite_array.select { |c| c.inviters_count_by_type(args[0]) == min }
        #    end
        #  else
        #    super
        #  end
        #end

      end

      # see if this model is invitee of some model
      #
      # Example:
      #   >> @ruby.invitee_of?(@jim)
      #   => true

      def invitee_of?(model)
        0 < self.inviters.by_model(model).limit(1).count * model.invitees.by_model(self).limit(1).count
      end

      # return true if self is invited by some models
      #
      # Example:
      #   >> @ruby.invited?
      #   => true

      def invited?
        0 < self.inviters.length
      end

      # get all the inviters of this model, same with classmethod inviters_of
      #
      # Example:
      #   >> @ruby.all_inviters
      #   => [@jim]

      def all_inviters(page = nil, per_page = nil)
        pipeline = [
          { '$project' =>
            { _id: 0,
              f_id: 1,
              inviteable_id: 1,
              inviteable_type: 1
            }
          },
          {
            '$match' => {
              'inviteable_id' => self.id,
              'inviteable_type' => self.class.name.split('::').last
            }
          }
        ]

        if page && per_page
          pipeline << { '$skip' => (page * per_page) }
          pipeline << { '$limit' => per_page }
        end

        pipeline << { '$project' => { f_id: 1 } }

        command = {
          aggregate: 'invites',
          pipeline: pipeline
        }

        if defined?(Mongoid)
          db = Mongoid.default_session
        elsif defined?(MongoMapper)
          db = MongoMapper.database
        end

        users_hash = db.command(command)['result']

        ids = users_hash.map {|e| e['f_id']}

        User.where(id: { '$in' => ids }).all.entries
      end

      def uninvited(*models, &block)
        if block_given?
          models.delete_if { |model| !yield(model) }
        end

        models.each do |model|
          unless model == self or !self.invitee_of?(model) or !model.inviter_of?(self)
            model.invitees.by_model(self).first.destroy
            self.inviters.by_model(model).first.destroy
          end
        end
      end

      # uninvite all

      def uninvited_all
        uninvited(*self.all_inviters)
      end

      # get all the inviters of this model in certain type
      #
      # Example:
      #   >> @ruby.inviters_by_type("user")
      #   => [@jim]

      def inviters_by_type(type)
        rebuild_instances(self.inviters.by_type(type))
      end

      # get the number of inviters
      #
      # Example:
      #   >> @ruby.inviters_count
      #   => 1

      def inviters_count
        self.inviters.count
      end

      # get the number of inviters in certain type
      #
      # Example:
      #   >> @ruby.inviters_count_by_type("user")
      #   => 1

      def inviters_count_by_type(type)
        self.inviters.by_type(type).count
      end

      # return if there is any common inviters
      #
      # Example:
      #   >> @ruby.common_invitees?(@python)
      #   => true

      def common_inviters?(model)
        0 < (rebuild_instances(self.inviters) & rebuild_instances(model.inviters)).length
      end

      # get common inviters with some model
      #
      # Example:
      #   >> @ruby.common_inviters_with(@python)
      #   => [@jim]

      def common_inviters_with(model)
        rebuild_instances(self.inviters) & rebuild_instances(model.inviters)
      end

      private
        def rebuild_instances(invites) #:nodoc:
          invites.group_by(&:f_type).inject([]) { |r, (k, v)| r += k.constantize.find(v.map(&:f_id)).to_a }
          #invite_list = []
          #invites.each do |invite|
          #  invite_list << invite.f_type.constantize.find(invite.f_id)
          #end
          #invite_list
        end
    end
  end
end
