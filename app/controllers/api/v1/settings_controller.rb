module Api
  module V1
    class SettingsController < ApplicationController
      before_action :set_customer
      
      # PUT /api/v1/settings/:customer_id
      def update
        # Update customer settings with hardcoded FAQ and contact info
        customer_updates = build_customer_updates
        
        if @customer.update(customer_updates)
          render json: {
            message: "Settings updated successfully",
            customer: format_customer_response,
            faq: hardcoded_faq,
            contact_info: hardcoded_contact_info
          }, status: :ok
        else
          render json: { 
            errors: @customer.errors.full_messages 
          }, status: :unprocessable_entity
        end
      end
      
      # GET /api/v1/settings/:customer_id
      def show
        render json: {
          customer: format_customer_response,
          faq: hardcoded_faq,
          contact_info: hardcoded_contact_info
        }, status: :ok
      end
      
      private
      
      def set_customer
        @customer = Customer.find(params[:customer_id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Customer not found" }, status: :not_found
      end
      
      def build_customer_updates
        updates = {}
        
        # Address updates
        updates[:address] = params[:address] if params[:address].present?
        updates[:shipping_address] = params[:shipping_address] if params[:shipping_address].present?
        updates[:address_landmark] = params[:address_landmark] if params[:address_landmark].present?
        updates[:address_type] = params[:address_type] if params[:address_type].present?
        updates[:latitude] = params[:latitude] if params[:latitude].present?
        updates[:longitude] = params[:longitude] if params[:longitude].present?
        
        # Delivery slot updates
        updates[:delivery_time_preference] = params[:delivery_slot] if params[:delivery_slot].present?
        
        # Language updates
        updates[:preferred_language] = params[:preferred_language] if params[:preferred_language].present?
        
        # Contact info updates
        updates[:phone_number] = params[:phone_number] if params[:phone_number].present?
        updates[:alt_phone_number] = params[:alt_phone_number] if params[:alt_phone_number].present?
        updates[:email] = params[:email] if params[:email].present?
        updates[:notification_method] = params[:notification_method] if params[:notification_method].present?
        
        # Parse delivery preferences if provided
        if params[:delivery_preferences].present?
          updates[:delivery_preferences] = parse_delivery_preferences(params[:delivery_preferences])
        end
        
        updates
      end
      
      def format_customer_response
        {
          id: @customer.id,
          name: @customer.user_name,
          address: @customer.address,
          shipping_address: @customer.shipping_address,
          address_landmark: @customer.address_landmark,
          address_type: @customer.address_type,
          latitude: @customer.latitude,
          longitude: @customer.longitude,
          delivery_slot: @customer.delivery_time_preference,
          preferred_language: @customer.preferred_language,
          phone_number: @customer.phone_number,
          alt_phone_number: @customer.alt_phone_number,
          email: @customer.email,
          notification_method: @customer.notification_method,
          delivery_preferences: @customer.delivery_preferences
        }
      end
      
      def hardcoded_faq
        [
          {
            id: 1,
            question: "How do I change my delivery address?",
            answer: "You can update your delivery address in the Settings section of the app. Go to Settings > Address and enter your new address details."
          },
          {
            id: 2,
            question: "What delivery slots are available?",
            answer: "We offer three delivery slots: Morning (8 AM - 12 PM), Afternoon (12 PM - 4 PM), and Evening (4 PM - 8 PM). You can choose your preferred slot in Settings."
          },
          {
            id: 3,
            question: "How can I change my preferred language?",
            answer: "We support multiple languages including English, Hindi, Telugu, Tamil, and Kannada. You can change your language preference in Settings > Language."
          },
          {
            id: 4,
            question: "What if I'm not available during delivery?",
            answer: "Please ensure someone is available at the delivery address. You can also add alternative contact details in your settings for backup communication."
          },
          {
            id: 5,
            question: "How do I update my contact information?",
            answer: "You can update your phone number, email, and notification preferences in the Settings section. We recommend keeping your contact information up to date."
          },
          {
            id: 6,
            question: "Can I have different billing and shipping addresses?",
            answer: "Yes, you can set different addresses for billing and shipping in your settings. This is useful for office deliveries or gifting."
          },
          {
            id: 7,
            question: "How do I cancel or modify my subscription?",
            answer: "You can manage your subscriptions in the app. Go to My Subscriptions to pause, modify, or cancel your regular deliveries."
          },
          {
            id: 8,
            question: "What payment methods do you accept?",
            answer: "We accept UPI, credit/debit cards, net banking, and cash on delivery. You can manage your payment methods in the app."
          }
        ]
      end
      
      def hardcoded_contact_info
        {
          customer_support: {
            phone: "+91-8800123456",
            email: "support@freshdelivery.com",
            whatsapp: "+91-8800123456",
            hours: "24/7 Support Available"
          },
          emergency_contact: {
            phone: "+91-8800654321",
            email: "emergency@freshdelivery.com",
            description: "For urgent delivery issues"
          },
          business_hours: {
            monday_friday: "8:00 AM - 10:00 PM",
            saturday: "8:00 AM - 10:00 PM",
            sunday: "9:00 AM - 9:00 PM"
          },
          office_address: {
            street: "123 Fresh Market Street",
            city: "Bangalore",
            state: "Karnataka",
            pincode: "560001",
            country: "India"
          },
          social_media: {
            facebook: "@freshdeliveryapp",
            twitter: "@freshdelivery",
            instagram: "@freshdelivery_official",
            youtube: "@freshdelivery"
          }
        }
      end
      
      def parse_delivery_preferences(preferences_param)
        return nil unless preferences_param.present?
        
        if preferences_param.is_a?(String)
          JSON.parse(preferences_param)
        elsif preferences_param.is_a?(Hash)
          preferences_param
        else
          nil
        end
      rescue JSON::ParserError
        nil
      end
    end
  end
end