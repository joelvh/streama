module Streama
  
  module Actor
    
    def self.included(base)
      base.extend(ClassMethods)
      base.class_eval do
        activity_stream(:default, :followers => :followers)
      end
    end
    
    def publish_activity(name, options={})
      receivers = options.delete(:receivers) || :default
      activity = Streama::Activity.new_with_data(name, {:actor => self}.merge(options))
      activity.publish(:receivers => receivers)
    end
    
    def activity_stream(options = {})
      options = {:page => 1, :per_page => 20}.merge(options)
      
      conditions = { :receiver_id => self.id, :receiver_type => self.class.name }
      conditions.merge!({:activity_type => options[:type]}) if options[:type]

      stream = Streama::Stream.where(conditions).desc(:created_at)
                              .paginate(:page => options[:page], :per_page => options[:per_page])
      
      activities = Streama::Activity.where(:_id.in => stream.map(&:activity_id)).desc(:created_at)
      
      WillPaginate::Collection.create(options[:page], options[:per_page], stream.total_entries) do |pager|
        pager.replace(activities)
      end
    end
    
    def followers
      self.class.all
    end
    
    module ClassMethods
      
      attr_accessor :streams
      
      def activity_stream(name, options={})
        (self.streams ||= {})[name.to_sym] = options
      end
      
    end
    
  end
  
end