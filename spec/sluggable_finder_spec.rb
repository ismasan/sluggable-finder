# encoding: UTF-8
$KCODE = "UTF-8"
require File.dirname(File.expand_path(__FILE__)) + '/spec_helper'

ActiveRecord::Base.establish_connection(
  :adapter =>'sqlite3',
  :database => File.join(File.dirname(__FILE__),'db','test.db'),
  :host => 'localhost',
  :database => 'spec/db/sluggable_finder_test',
  :user => 'root',
  :password => ''
)

LOGGER = Logger.new(STDOUT)
ActiveRecord::Base.logger = LOGGER

# A test Model according to test schema in db/test.db
#
class Item < ActiveRecord::Base
  named_scope :published, :conditions => {:published => true}
end

class StiParent < Item
  sluggable_finder :title, :ignore_sti => true
end

class StiChild < StiParent
  
end

# No sluggable finder, should be unnaffected
#
class NoFinder < Item

end
# Simple slug
#
class SimpleItem < Item
  sluggable_finder :title, :reserved_slugs => ['admin','settings'] # defaults :to => :slug
end

class SimpleUpcaseItem < Item
  sluggable_finder :title, :upcase => true
end

class StringOnlyItem < Item
  sluggable_finder :title, :allow_integer_ids => false
end

# Slug from virtual attribute
#
class VirtualItem < Item
  sluggable_finder :some_method
  
  def some_method
    "#{self.class.name} #{title}"
  end
  
end

# This one saves slug into 'permalink' field
#
class PermalinkItem < Item
  sluggable_finder :title, :to => :permalink
end

# A top level object to test scoped slugs
#
class Category < ActiveRecord::Base
  has_many :scoped_items
  has_many :simple_items
  has_many :string_only_items
end

class ScopedItem < Item
  belongs_to :category
  sluggable_finder :title, :scope => :category_id
end

describe "random slugs" do
  it "should generate random slugs" do
    SluggableFinder.random_slug_for(String).should_not be_nil
  end
end

describe "SluggableFinder" do
  before do
    Item.delete_all
    Category.delete_all
  end
  describe SimpleItem, 'encoding permalinks' do
    before(:each) do
      @item = SimpleItem.create!(:title => 'Hello World')
      @item2 = SimpleItem.create(:title => 'Hello World')
      @item3 = SimpleItem.create(:title => 'Admin')
    end

    it "should connect to test sqlite db" do
      Item.count.should == 3
    end

    it "should create unique slugs" do
      @item.slug.should == 'hello-world'
      @item2.slug.should == 'hello-world-2'
    end

    it "should define to_param to return slug" do
      @item.to_param.should == 'hello-world'
    end

    it "should raise ActiveRecord::RecordNotFound" do
      SimpleItem.create!(:title => 'Hello World')
      lambda {
        SimpleItem.find 'non-existing-slug'
      }.should raise_error(ActiveRecord::RecordNotFound)
    end

    it "should find normally by ID" do
      SimpleItem.find(@item.id).should == @item
    end

    it "should find by ID even if ID is string" do
      SimpleItem.find(@item.id.to_s).should == @item
    end

    it "should not create reserved slug" do
      lambda {
        SimpleItem.find 'admin'
      }.should raise_error(ActiveRecord::RecordNotFound)
      SimpleItem.find('admin-2').to_param.should == @item3.to_param
    end

    it "should keep original slugs" do
      @item.title = 'some other title'
      @item.save
      @item.to_param.should == 'hello-world'
    end

    it "should store random slug if field is nil" do
     item = SimpleItem.create!(:title => nil)
     item.to_param.should_not be_blank
    end
  end
  
  describe SimpleUpcaseItem, 'uppercase slugs' do
    
    it 'should uppercase slugs' do
      item = SimpleUpcaseItem.create!(:title => 'tHis Should be Capitalized 1977')
      item.to_param.should == 'THIS-SHOULD-BE-CAPITALIZED-1977'
    end
  end
  
  describe ':allow_integer_ids => false' do
    
    before do
      @item = StringOnlyItem.create!(:title => 'Hello World')
      @item2 = StringOnlyItem.create!(:title => '1234567890')
    end
    
    it 'should work by string permalink' do
      StringOnlyItem.find('hello-world').should == @item
    end
    
    it 'should NOT allow real ID' do
      lambda {
        StringOnlyItem.find(@item.id)
      }.should raise_error(ActiveRecord::RecordNotFound)
    end
    
    it 'should find by integer-like slugs' do
      StringOnlyItem.find('1234567890').should == @item2
      StringOnlyItem.find(1234567890).should == @item2
    end
    
    describe 'with nested models' do
      
      before do
        @category = Category.create(:name => 'foo')
        @item1 = @category.string_only_items.create(:title => 'scoped string only')
        @item2 = @category.string_only_items.create(:title => '987654321')
      end
      
      it 'should work by string permalink' do
        @category.string_only_items.find('scoped-string-only').should == @item1
      end
      
      it 'should NOT allow integer ID' do
        lambda {
          @category.string_only_items.find(@item1.id)
        }.should raise_error(ActiveRecord::RecordNotFound)
      end
      
      it 'should find by integer-like slugs' do
        @category.string_only_items.find('987654321').should == @item2
        @category.string_only_items.find(987654321).should == @item2
      end
    end
  end

  # Raising custom not found exceptions allows us to use this with merb's NotFound exception
  # or any framework
  describe "with custom exception" do
    it "should raise custom exception if configured that way" do
      class CustomException < StandardError;end

      SluggableFinder.not_found_exception = CustomException
      lambda {
        SimpleItem.find 'non-existing-slug'
      }.should raise_error(CustomException)
    end

    after(:all) do
      SluggableFinder.not_found_exception = ActiveRecord::RecordNotFound
    end
  end

  describe SimpleItem, "with non-english characters" do
    before(:each) do
      @item = SimpleItem.create!(:title => "Un ñandú super ñoño I've seen")
    end

    it "should turn them to english characters" do
      @item.to_param.should == "un-nandu-super-nono-i-ve-seen"
    end
  end

  describe VirtualItem, 'using virtual fields as permalink source' do
    before(:each) do
      @item = VirtualItem.create!(:title => 'prefixed title')
    end

    it "should generate slug from a virtual attribute" do
      @item.to_param.should == 'virtualitem-prefixed-title'
    end

    it "should find by slug" do
      VirtualItem.find('virtualitem-prefixed-title').to_param.should == @item.to_param
    end
  end

  describe PermalinkItem,'writing to custom field' do
    before(:each) do
      @item = PermalinkItem.create! :title => 'Hello World'
    end

    it "should create slug in custom field if provided" do

      @item.permalink.should == 'hello-world'
      @item.slug.should == nil
    end
  end

  describe SimpleItem,"scoping finder" do
    before(:each) do
      @category1 = Category.create!(:name => 'Category one')
      @category2 = Category.create!(:name => 'Category two')
      # Lets create 3 items with the same title, two of them in the same category
      @item1 = @category1.simple_items.create!(:title => '1 in 1')
      @item2 = @category1.simple_items.create!(:title => '2 in 1')
      @item3 = @category2.simple_items.create!(:title => '1 in 2')
    end

    it "should find in scope" do
      @category1.simple_items.find('1-in-1').should == @item1
    end

    it "should not find out of scope" do
      lambda{
        @category2.simple_items.find('1-in-1')
      }.should raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe ScopedItem,'scoped to parent object' do
    before(:each) do
      @category1 = Category.create!(:name => 'Category one')
      @category2 = Category.create!(:name => 'Category two')
      # Lets create 3 items with the same title, two of them in the same category
      @item1 = @category1.scoped_items.create!(:title => 'A scoped item',:published => true)
      @item2 = @category1.scoped_items.create!(:title => 'A scoped item', :published => false)
      @item3 = @category2.scoped_items.create!(:title => 'A scoped item')
    end

    it "should scope slugs to parent items" do
      @item1.to_param.should == 'a-scoped-item'
      @item2.to_param.should == 'a-scoped-item-2' # because this slug is not available for this category
      @item3.to_param.should == 'a-scoped-item'
    end

    it "should include sluggable methods in collections" do
      @category1.scoped_items.respond_to?(:find_with_slug).should == true 
    end

    it "should find by scoped slug" do
      item1 = @category1.scoped_items.find('a-scoped-item')
      item1.to_param.should == @item1.to_param
    end

    it "should find published one (named scope)" do
      @category1.scoped_items.published.find('a-scoped-item').to_param.should == @item1.to_param
    end

    it "should not find unpublished one (named scope)" do
      lambda{
        @category1.scoped_items.published.find('a-scoped-item-2')
      }.should raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe SimpleItem, 'with AR named scopes' do
    before(:each) do
      @published_one  = SimpleItem.create! :title => 'published 1',:published => true
      @published_two  = SimpleItem.create! :title => 'published 2',:published => true
      @unpublished    = SimpleItem.create! :title => 'not published',:published => false
    end

    it "should find published ones" do
      SimpleItem.published.find('published-1').to_param.should == @published_one.to_param
      SimpleItem.published.find('published-2').to_param.should == @published_two.to_param
    end

    it "should not find unpublished ones" do
      lambda {
        SimpleItem.published.find('not-published')
      }.should raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe NoFinder, "with no finder" do
    before(:each) do
      @item = NoFinder.create(:title => 'no finder here')
      @string_id = "#{@item.id}-some-string"
    end

    it "should use find normally" do
      NoFinder.find(:first).should == @item
      NoFinder.find(@item.id).should == @item
      NoFinder.find(@string_id).should == @item
    end
  end
  
  describe 'collection setters' do
    before do
      @item1 = SimpleItem.create(:title => 'item1')
      @item2 = SimpleItem.create(:title => 'item12')
      @category = Category.create(:name => 'Cat1')
    end
    
    it 'should assign children ids' do
      @category.simple_item_ids = [@item1.id, @item2.id]
      @category.simple_items.should == [@item1, @item2]
    end
    
    it 'should not break when assigning empty array' do
      lambda {
       @category.simple_item_ids = []
      }.should_not raise_error
    end
  end
  
  describe 'STI scope' do
    before do
      @sti1 = StiParent.create(:title => 'Slug')
      @sti2 = StiChild.create(:title => 'Slug')
    end
    
    it 'should not auto increment slugs' do
      @sti1.slug.should == 'slug'
      @sti2.slug.should == 'slug'
    end
  end
end