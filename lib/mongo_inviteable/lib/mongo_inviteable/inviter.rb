module Mongo
  module Inviteable
    module Inviter
     extend ActiveSupport::Concern

     included do |base|
       if defined?(Mongoid)
         base.has_many :invitees, :class_name => "Invite", :as => :inviting, :dependent => :destroy
       elsif defined?(MongoMapper)
         base.many :invitees, :class_name => "Invite", :as => :inviting, :dependent => :destroy
       end
     end

     module ClassMethods

       # get certain model's inviters of this type
       #
       # Example:
       #   >> @jim = User.new
       #   >> @ruby = Group.new
       #   >> @jim.save
       #   >> @ruby.save
       #
       #   >> @jim.invite(@ruby)
       #   >> User.inviters_of(@ruby)
       #   => [@jim]
       #
       #   Arguments:
       #     model: instance of some inviteable model

       def inviters_of(model)
         model.inviters_by_type(self.name)
       end

       # 4 methods in this function
       #
       # Example:
       #   >> User.with_max_invitees
       #   => [@jim]
       #   >> User.with_max_invitees_by_type('group')
       #   => [@jim]

       ["max", "min"].each do |s|
         define_method(:"with_#{s}_invitees") do
           invite_array = self.all.to_a.sort! { |a, b| a.invitees_count <=> b.invitees_count }
           num = invite_array[-1].invitees_count
           invite_array.select { |c| c.invitees_count == num }
         end

         define_method(:"with_#{s}_invitees_by_type") do |*args|
           invite_array = self.all.to_a.sort! { |a, b| a.invitees_count_by_type(args[0]) <=> b.invitees_count_by_type(args[0]) }
           num = invite_array[-1].invitees_count_by_type(args[0])
           invite_array.select { |c| c.invitees_count_by_type(args[0]) == num }
         end
       end

       #def method_missing(name, *args)
       #  if name.to_s =~ /^with_(max|min)_invitees$/i
       #    invite_array = self.all.to_a.sort! { |a, b| a.invitees_count <=> b.invitees_count }
       #    if $1 == "max"
       #      max = invite_array[-1].invitees_count
       #      invite_array.select { |c| c.invitees_count == max }
       #    elsif $1 == "min"
       #      min = invite_array[0].invitees_count
       #      invite_array.select { |c| c.invitees_count == min }
       #    end
       #  elsif name.to_s =~ /^with_(max|min)_invitees_by_type$/i
       #    invite_array = self.all.to_a.sort! { |a, b| a.invitees_count_by_type(args[0]) <=> b.invitees_count_by_type(args[0]) }
       #    if $1 == "max"
       #      max = invite_array[-1].invitees_count_by_type(args[0])
       #      invite_array.select { |c| c.invitees_count_by_type(args[0]) == max }
       #    elsif $1 == "min"
       #      min = invite_array[0].invitees_count
       #      invite_array.select { |c| c.invitees_count_by_type(args[0]) == min }
       #    end
       #  else
       #    super
       #  end
       #end

     end

     # see if this model is inviter of some model
     #
     # Example:
     #   >> @jim.inviter_of?(@ruby)
     #   => true

     def inviter_of?(model)
       0 < self.invitees.by_model(model).limit(1).count * model.inviters.by_model(self).limit(1).count
     end

     # return true if self is inviting some models
     #
     # Example:
     #   >> @jim.inviting?
     #   => true

     def inviting?
       0 < self.invitees.length
     end

     # get all the invitees of this model, same with classmethod invitees_of
     #
     # Example:
     #   >> @jim.all_invitees
     #   => [@ruby]

     def all_invitees
       rebuild_instances(self.invitees)
     end

     # get all the invitees of this model in certain type
     #
     # Example:
     #   >> @ruby.invitees_by_type("group")
     #   => [@ruby]

     def invitees_by_type(type)
       rebuild_instances(self.invitees.by_type(type))
     end

     # invite some model

     def invite(*models, &block)
       if block_given?
         models.delete_if { |model| !yield(model) }
       end

       models.each do |model|
         unless model == self or self.inviter_of?(model) or model.invitee_of?(self)
           model.inviters.create!(:f_type => self.class.name, :f_id => self.id.to_s)
           self.invitees.create!(:f_type => model.class.name, :f_id => model.id.to_s)

           model.invited_history << self.class.name + '_' + self.id.to_s if model.respond_to? :invited_history
           self.invite_history << model.class.name + '_' + model.id.to_s if self.respond_to? :invite_history

           model.save
           self.save
         end
       end
     end

     # uninvite some model

     def uninvite(*models, &block)
       if block_given?
         models.delete_if { |model| !yield(model) }
       end

       models.each do |model|
         unless model == self or !self.inviter_of?(model) or !model.invitee_of?(self)
           model.inviters.by_model(self).first.destroy
           self.invitees.by_model(model).first.destroy
         end
       end
     end

     # uninvite all

     def uninvite_all
       uninvite(*self.all_invitees)
     end

     # get the number of invitees
     #
     # Example:
     #   >> @jim.inviters_count
     #   => 1

     def invitees_count
       self.invitees.count
     end

     # get the number of inviters in certain type
     #
     # Example:
     #   >> @ruby.inviters_count_by_type("user")
     #   => 1

     def invitees_count_by_type(type)
       self.invitees.by_type(type).count
     end

     # return if there is any common invitees
     #
     # Example:
     #   >> @jim.common_invitees?(@tom)
     #   => true

     def common_invitees?(model)
       0 < (rebuild_instances(self.invitees) & rebuild_instances(model.invitees)).length
     end

     # get common invitees with some model
     #
     # Example:
     #   >> @jim.common_invitees_with(@tom)
     #   => [@ruby]

     def common_invitees_with(model)
       rebuild_instances(self.invitees) & rebuild_instances(model.invitees)
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
