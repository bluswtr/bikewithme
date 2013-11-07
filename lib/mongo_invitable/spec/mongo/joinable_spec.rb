require 'spec_helper'

describe Mongo::Invitable do
  describe User do
    let!(:u) { User.create! }

    context "begins" do
      let!(:v) { User.create! }
      let!(:w) { User.create! }
      let!(:g) { Group.create! }

      it "inviting a user" do
        u.invit(v, g)

        u.inviting?.should be_true
        v.invited?.should be_true
        g.invited?.should be_true

        u.inviter_of?(v).should be_true
        v.invitee_of?(u).should be_true

        u.all_invitees.should == [v, g]
        v.all_inviters.should == [u]

        u.invitees_by_type("user").should == [v]
        v.inviters_by_type("user").should == [u]

        u.invitees_count.should == 2
        v.inviters_count.should == 1

        u.invitees_count_by_type("user").should == 1
        v.inviters_count_by_type("user").should == 1

        u.ever_invit.should =~ [v, g]
        v.ever_invited.should == [u]

        u.ever_invit?(v).should be_true
        u.ever_invit?(g).should be_true
        v.ever_invited?(u).should be_true

        u.common_invitees?(v).should be_false
        v.common_inviters?(u).should be_false
        u.common_invitees_with(v).should == []
        v.common_inviters_with(u).should == []

        User.with_max_invitees.should == [u]
        User.with_max_inviters.should == [v]
        User.with_max_invitees_by_type('user').should == [u]
        User.with_max_inviters_by_type('user').should == [v]
      end

      it "uninviting" do
        u.uninvit_all

        u.inviter_of?(v).should be_false
        v.invitee_of?(u).should be_false

        u.all_invitees.should == []
        v.all_inviters.should == []

        u.invitees_by_type("user").should == []
        v.inviters_by_type("user").should == []

        u.invitees_count.should == 0
        v.inviters_count.should == 0

        u.invitees_count_by_type("user").should == 0
        v.inviters_count_by_type("user").should == 0
      end

      it "inviting a group" do
        u.invit(g)

        u.inviter_of?(g).should be_true
        g.invitee_of?(u).should be_true

        u.all_invitees.should == [g]
        g.all_inviters.should == [u]

        u.invitees_by_type("group").should == [g]
        g.inviters_by_type("user").should == [u]

        u.invitees_count.should == 1
        g.inviters_count.should == 1

        u.invitees_count_by_type("group").should == 1
        g.inviters_count_by_type("user").should == 1

        u.invit(v)

        u.ever_invit.should =~ [g, v]
        g.ever_invited.should == [u]

        u.clear_invit_history!
        u.ever_invit.should == []

        g.clear_history!
        g.ever_invited.should == []

        u.common_invitees?(v).should be_false
        v.common_inviters?(g).should be_true
        u.common_invitees_with(v).should == []
        v.common_inviters_with(g).should == [u]

        User.with_max_invitees.should == [u]
        Group.with_max_inviters.should == [g]
        User.with_max_invitees_by_type('group').should == [u]
        Group.with_max_inviters_by_type('user').should == [g]
      end

      it "uninviting a group" do
        u.uninvit(g)

        u.inviter_of?(g).should be_false
        g.invitee_of?(u).should be_false

        u.all_invitees.should == []
        g.all_inviters.should == []

        u.invitees_by_type("group").should == []
        g.inviters_by_type("group").should == []

        u.invitees_count.should == 0
        g.inviters_count.should == 0

        u.invitees_count_by_type("group").should == 0
        g.inviters_count_by_type("group").should == 0
      end
    end
  end

  describe Group do
    let!(:g) { Group.create! }
    context "begins" do
      let(:v) { User.create! }
      let(:w) { User.create! }
      let(:u) { User.create! }

      it "another way to uninvit a group" do
        u.invit(g)
        v.invit(g)
        w.invit(g)

        g.all_inviters.should =~ [v,u,w]

        w.inviter_of?(g).should be_true
        g.invitee_of?(w).should be_true

        #g.uninvited(w)

        u.inviter_of?(g).should be_true
        g.invitee_of?(u).should be_true

        v.inviter_of?(g).should be_true
        g.invitee_of?(v).should be_true

        #g.all_inviters.should =~ [v,u]

        g.uninvited_all

        g.all_inviters == []
      end

      it "another way to uninvit a group" do
        u.invit(g)
        g.uninvited(u)
      end

      it "another way to uninvit a group" do
        g.all_inviters.should == []
      end
    end
  end

  describe User do
    let(:u) { User.create! }

    context "begins" do
      let(:v) { User.create! }
      let(:w) { User.create! }
      let(:g) { Group.create! }

      it "block test" do
        u.invit(v, w, g) {|m| m.class == User}

        u.all_invitees.should =~ [v, w]
      end

      it "block test uninvit" do
        u.uninvit(v, w, g) {|m| m.invitee_of? u}

        u.all_invitees.should == []
      end
    end
  end

  describe ChildUser do
     let(:v) { ChildUser.create! }

    context "begins" do
      let(:u) { User.create! }
      let(:w) { User.create! }
      let(:g) { Group.create! }

      it "inherited model test" do
        u.invit(v, w, g) {|m| m.class == User}

        u.all_invitees.should == [w]

        u.invitees_by_type("user") == [w]

        w.inviters_by_type("child_user") == [u]
        w.inviters_by_type("childUser") == [u]
        w.inviters_by_type("ChildUser") == [u]
      end
    end
  end
end

