require 'spec_helper'

describe Hudhub::Job do

  let(:response_200) do
    mock('response', :code => 200)
  end

  before do
    Hudhub::Job::Http.stub!(:get) { response_200 }
    Hudhub::Job::Http.stub!(:post) { response_200 }
  end

  let(:base_job) { Hudhub::Job.new('my_project_master_rspec', 'RANDOM_XML_<name>master</name>_MORE_RANDOM_XML')}
  let(:job) { Hudhub::Job.new('my_project_new-branch_rspec', 'RANDOM_XML_<name>new-branch</name>_MORE_RANDOM_XML')}

  describe "#name_for_branch" do
    context "when my-project-master-rspec" do
      subject { Hudhub::Job.name_for_branch("my-project-master-rspec", "new-branch") }
      it { should == "my-project-new-branch-rspec" }
    end
    context "when my-project-rspec" do
      subject { Hudhub::Job.name_for_branch("my-project-rspec", "new-branch") }
      it { should == "my-project-rspec-new-branch" }
    end
  end

  describe "#update_branch!" do
    context "when branch is 'new-branch'" do
      subject { base_job.update_branch!('new-branch')}

      its(:name) { should == 'my_project_new-branch_rspec'}
      its(:data) { should == 'RANDOM_XML_<name>new-branch</name>_MORE_RANDOM_XML' }
    end
  end

  describe "##find_or_create_copy" do
    context "when job exists" do
      it "should return the job" do
        Hudhub::Job.should_receive(:find).with('my_project_new-branch_spec') { job }
        Hudhub::Job.find_or_create_copy('my_project_master_spec', 'new-branch').should == job
      end
    end
    context "when job does not exists" do
      it "should create a copy" do
        Hudhub::Job.should_receive(:find).with('my_project_new-branch_spec') { nil }
        Hudhub::Job.should_receive(:find).with('my_project_master_spec') { base_job }
        Hudhub::Job.should_receive(:copy!).with(base_job, 'new-branch') { job }

        Hudhub::Job.find_or_create_copy('my_project_master_spec', 'new-branch').should == job
      end
    end
  end

  describe "##copy!" do
    it "should create a job based on the base one" do
      Hudhub::Job::Http.should_receive(:post).
        with("/createItem?name=my_project_new-branch_rspec",
             {:body=>"RANDOM_XML_<name>new-branch</name>_MORE_RANDOM_XML"}) { response_200 }
      Hudhub::Job.copy!(base_job, 'new-branch')
    end
    describe "the job returned" do
      subject { Hudhub::Job.copy!(base_job, 'new-branch')}

      its(:name) { should == 'my_project_new-branch_rspec' }
      its(:data) { should == 'RANDOM_XML_<name>new-branch</name>_MORE_RANDOM_XML' }
    end
  end

  describe "##delete!" do
    it "should delete the job" do
      Hudhub::Job::Http.should_receive(:post).
        with("/job/my_project_old-branch_rspec/doDelete")
      Hudhub::Job.delete!(base_job.name, 'old-branch')
    end

  end
end
