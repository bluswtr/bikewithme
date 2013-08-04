##
# A class that loads descriptors that relate to forms and their
# respective database objects. For now, we are loading
# descriptors that pertain to bike rides only.
#
class Descriptor
  include Mongoid::Document
	field :activity_id, :type => Integer
	field :descriptor

	##
	# Array position = Option value in form = value stored in database
	# BE WARNED: modifying the db/descriptors.txt and running a rake db:seeds
	# is bad unless you add more functionality to handle the documents your changes
	# affect. Also, deprecation of options is not handled anywhere. 
	#
	# This solution was chosen solely for its simplicity and ease of implementation
	field :options, :type => Array

	##
	# Returns an array of pairs. Each pair 
	# contains option and a corresponding value for a select tag
	# such as: [['Flat',1],['Rollers',2],['Hilly',3],['Steep',4]]
	def self.format_for_option_tag(activity_id)
		descriptors = Hash.new
		Descriptor.where(activity_id: 1).each do |object|
			options = Array.new
			i = 0
			object.options.each do |option|
				options << [option,i]
				i+=1
			end
			descriptors[object.descriptor] = options
		end
		descriptors
	end

	##
	# Returns an array of hashes
	def self.get_options
		# return format for html content in map
		# double array?
		descriptors = Hash.new
		Descriptor.where(activity_id: 1).each do |object|
			descriptors[object.descriptor] = object.options
		end
		p descriptors
	end
end