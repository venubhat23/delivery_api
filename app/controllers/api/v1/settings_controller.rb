module Api
  module V1
    class SettingsController < ApplicationController
      before_action :authenticate_request

      # GET /api/v1/settings - Comprehensive settings endpoint
      def index
        admin = AdminSetting.first
        customer = current_user.is_a?(Customer) ? current_user : current_user&.customer
        locale = params[:locale] || 'en'

        render json: {
          user: user_summary(customer),
          appSettings: build_app_settings(customer, locale),
          deliveryPreferences: build_delivery_preferences(customer),
          addresses: build_addresses(customer),
          referral: build_referral(customer),
          faq: build_faq_data(locale),
          cms: build_cms_metadata(locale),
          contact: build_contact(admin),
          supportTickets: build_support_tickets(customer)
        }, status: :ok
      end

      # POST /api/v1/settings/faq/ask - User can ask questions
      def ask_question
        customer = current_user.is_a?(Customer) ? current_user : current_user&.customer
        return render json: { error: 'Customer not found' }, status: :not_found unless customer

        faq = customer.faqs.build(
          question: params[:question],
          category: params[:category] || 'general',
          locale: params[:locale] || 'en',
          submitted_by_user: true,
          status: :pending,
          is_active: false
        )

        if faq.save
          render json: { 
            success: true,
            message: 'Question submitted successfully', 
            faq: {
              id: faq.id,
              question: faq.question,
              category: faq.category,
              status: faq.status
            }
          }, status: :created
        else
          render json: { 
            success: false,
            errors: faq.errors.full_messages 
          }, status: :unprocessable_entity
        end
      end

      # POST /api/v1/settings/contact - Contact/Support form
      def contact
        customer = current_user.is_a?(Customer) ? current_user : current_user&.customer
        return render json: { error: 'Customer not found' }, status: :not_found unless customer

        ticket = customer.support_tickets.build(
          subject: params[:subject],
          message: params[:message],
          channel: 'app',
          priority: params[:priority] || 'low',
          status: 'open'
        )

        if ticket.save
          render json: { 
            success: true,
            message: 'Support request submitted successfully', 
            ticket: {
              id: ticket.id,
              subject: ticket.subject,
              status: ticket.status,
              priority: ticket.priority
            }
          }, status: :created
        else
          render json: { 
            success: false,
            errors: ticket.errors.full_messages 
          }, status: :unprocessable_entity
        end
      end

      # PUT /api/v1/settings/language - Update app language
      def update_language
        customer = current_user.is_a?(Customer) ? current_user : current_user&.customer
        return render json: { error: 'Customer not found' }, status: :not_found unless customer

        preferences = customer.customer_preference || customer.build_customer_preference
        
        if preferences.update(language: params[:language])
          render json: { 
            success: true,
            message: 'Language updated successfully',
            language: preferences.language
          }, status: :ok
        else
          render json: { 
            success: false,
            errors: preferences.errors.full_messages 
          }, status: :unprocessable_entity
        end
      end

      # PUT /api/v1/settings/delivery-preferences - Update delivery preferences
      def update_delivery_preferences
        customer = current_user.is_a?(Customer) ? current_user : current_user&.customer
        return render json: { error: 'Customer not found' }, status: :not_found unless customer

        preferences = customer.customer_preference || customer.build_customer_preference
        
        if preferences.update(delivery_preference_params)
          render json: { 
            success: true,
            message: 'Delivery preferences updated successfully',
            preferences: build_delivery_preferences(customer)
          }, status: :ok
        else
          render json: { 
            success: false,
            errors: preferences.errors.full_messages 
          }, status: :unprocessable_entity
        end
      end

      # POST /api/v1/settings/addresses - Add new address
      def add_address
        customer = current_user.is_a?(Customer) ? current_user : current_user&.customer
        return render json: { error: 'Customer not found' }, status: :not_found unless customer

        address = customer.customer_addresses.build(address_params)

        if address.save
          render json: { 
            success: true,
            message: 'Address added successfully',
            address: format_address(address)
          }, status: :created
        else
          render json: { 
            success: false,
            errors: address.errors.full_messages 
          }, status: :unprocessable_entity
        end
      end

      # PUT /api/v1/settings/addresses/:id - Update address
      def update_address
        customer = current_user.is_a?(Customer) ? current_user : current_user&.customer
        return render json: { error: 'Customer not found' }, status: :not_found unless customer

        address = customer.customer_addresses.find(params[:id])

        if address.update(address_params)
          render json: { 
            success: true,
            message: 'Address updated successfully',
            address: format_address(address)
          }, status: :ok
        else
          render json: { 
            success: false,
            errors: address.errors.full_messages 
          }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/settings/addresses/:id - Delete address
      def delete_address
        customer = current_user.is_a?(Customer) ? current_user : current_user&.customer
        return render json: { error: 'Customer not found' }, status: :not_found unless customer

        address = customer.customer_addresses.find(params[:id])
        address.destroy

        render json: { 
          success: true,
          message: 'Address deleted successfully' 
        }, status: :ok
      end

      # POST /api/v1/settings/addresses/:id/set_default - Set default address
      def set_default_address
        customer = current_user.is_a?(Customer) ? current_user : current_user&.customer
        return render json: { error: 'Customer not found' }, status: :not_found unless customer

        address = customer.customer_addresses.find(params[:id])
        address.set_as_default!

        render json: { 
          success: true,
          message: 'Default address updated successfully',
          address: format_address(address)
        }, status: :ok
      end

      private

      # Build comprehensive app settings
      def build_app_settings(customer, locale)
        preferences = customer&.customer_preference
        {
          language: preferences&.language || locale,
          availableLanguages: [
            { code: 'en', name: 'English' },
            { code: 'hi', name: 'हिंदी' },
            { code: 'te', name: 'తెలుగు' },
            { code: 'ta', name: 'தமிழ்' },
            { code: 'kn', name: 'ಕನ್ನಡ' },
            { code: 'ml', name: 'മലയാളം' }
          ],
          notificationPreferences: preferences&.notification_settings || {},
          theme: 'light',
          version: '1.0.0'
        }
      end

      # Build delivery preferences with all details
      def build_delivery_preferences(customer)
        return default_delivery_preferences unless customer
        
        preferences = customer.customer_preference
        {
          timeWindow: {
            start: preferences&.delivery_time_start&.strftime('%H:%M'),
            end: preferences&.delivery_time_end&.strftime('%H:%M')
          },
          skipWeekends: preferences&.skip_weekends || false,
          specialInstructions: preferences&.special_instructions,
          notificationPreferences: preferences&.notification_settings || {},
          deliveryTimePreference: customer.delivery_time_preference,
          availableTimeSlots: [
            { value: '06:00-10:00', label: '6:00 AM - 10:00 AM' },
            { value: '10:00-14:00', label: '10:00 AM - 2:00 PM' },
            { value: '14:00-18:00', label: '2:00 PM - 6:00 PM' },
            { value: '18:00-22:00', label: '6:00 PM - 10:00 PM' }
          ]
        }
      end

      # Build addresses array
      def build_addresses(customer)
        return [] unless customer
        
        customer.customer_addresses.order(is_default: :desc, created_at: :desc).map do |address|
          format_address(address)
        end
      end

      # Build referral information with earnings
      def build_referral(customer)
        return nil unless customer
        
        ref = customer.referral_code
        if ref.nil?
          # Auto-generate referral code
          code = loop do
            candidate = SecureRandom.alphanumeric(8).upcase
            break candidate unless ReferralCode.exists?(code: candidate)
          end
          ref = customer.create_referral_code!(code: code, share_url_slug: code)
        end
        
        {
          code: ref.code,
          shareUrl: ref.share_url(request.base_url),
          creditsEarned: ref.total_credits,
          referralsCount: ref.total_referrals,
          description: "Share your referral code and earn credits for every successful referral!",
          benefits: [
            "Earn ₹50 credit for each successful referral",
            "Your friend gets ₹25 discount on first order",
            "No limit on referrals",
            "Credits can be used for future orders"
          ]
        }
      end

      # Build FAQ data with categories and search capability
      def build_faq_data(locale)
        faqs = Faq.published.for_locale(locale).ordered
        categories = faqs.group(:category).count
        
        {
          categories: categories.map { |cat, count| 
            { 
              title: cat, 
              count: count,
              displayName: cat.humanize
            } 
          },
          totalFaqs: faqs.count,
          recentFaqs: faqs.limit(5).as_json(
            only: [:id, :category, :question, :answer, :locale, :sort_order]
          ),
          canSubmitQuestions: true,
          submissionGuidelines: [
            "Please be specific with your question",
            "Check existing FAQs before submitting",
            "We'll respond within 24-48 hours"
          ]
        }
      end

      # Build CMS content metadata
      def build_cms_metadata(locale)
        terms = CmsPage.published.for_slug('terms-of-service').for_locale(locale).order(published_at: :desc).first
        privacy = CmsPage.published.for_slug('privacy-policy').for_locale(locale).order(published_at: :desc).first
        
        {
          termsOfService: terms ? {
            version: terms.version,
            lastUpdated: terms.published_at,
            title: terms.title,
            hasContent: terms.content.present?
          } : nil,
          privacyPolicy: privacy ? {
            version: privacy.version,
            lastUpdated: privacy.published_at,
            title: privacy.title,
            hasContent: privacy.content.present?
          } : nil
        }
      end

      # Build contact information
      def build_contact(admin)
        {
          email: admin&.email || 'support@company.com',
          phone: admin&.mobile,
          businessHours: '9:00 AM - 6:00 PM (Mon-Sat)',
          supportChannels: [
            { type: 'email', value: admin&.email, available: true },
            { type: 'phone', value: admin&.mobile, available: admin&.mobile.present? },
            { type: 'whatsapp', value: admin&.mobile, available: admin&.mobile.present? },
            { type: 'app', value: 'In-app support', available: true }
          ]
        }
      end

      # Build support tickets summary
      def build_support_tickets(customer)
        return { count: 0, recent: [] } unless customer
        
        tickets = customer.support_tickets.recent.limit(3)
        {
          totalCount: customer.support_tickets.count,
          openCount: customer.support_tickets.where(status: ['open', 'in_progress']).count,
          recent: tickets.as_json(
            only: [:id, :subject, :status, :priority, :created_at],
            methods: [:days_open]
          )
        }
      end

      # User summary with additional info
      def user_summary(customer)
        base_info = if current_user.is_a?(Customer)
          { id: current_user.id, name: current_user.name, type: 'customer' }
        elsif current_user.is_a?(User) && customer
          { id: customer.id, name: customer.name, type: 'customer' }
        else
          { id: current_user.id, name: current_user.name, type: 'user' }
        end
        
        if customer
          base_info.merge({
            phone: customer.phone_number,
            email: customer.email,
            memberSince: customer.created_at,
            isActive: customer.is_active,
            preferredLanguage: customer.preferred_language
          })
        else
          base_info
        end
      end

      # Helper methods
      def format_address(address)
        {
          id: address.id,
          type: address.address_type,
          typeLabel: address.address_type_label,
          streetAddress: address.street_address,
          city: address.city,
          state: address.state,
          pincode: address.pincode,
          landmark: address.landmark,
          isDefault: address.is_default,
          fullAddress: address.full_address,
          shortAddress: address.short_address
        }
      end

      def default_delivery_preferences
        {
          timeWindow: { start: nil, end: nil },
          skipWeekends: false,
          specialInstructions: nil,
          notificationPreferences: {},
          deliveryTimePreference: nil,
          availableTimeSlots: [
            { value: '06:00-10:00', label: '6:00 AM - 10:00 AM' },
            { value: '10:00-14:00', label: '10:00 AM - 2:00 PM' },
            { value: '14:00-18:00', label: '2:00 PM - 6:00 PM' },
            { value: '18:00-22:00', label: '6:00 PM - 10:00 PM' }
          ]
        }
      end

      # Parameter methods
      def delivery_preference_params
        params.permit(:delivery_time_start, :delivery_time_end, :skip_weekends, 
                     :special_instructions, notification_preferences: {})
      end

      def address_params
        params.permit(:address_type, :street_address, :city, :state, :pincode, 
                     :landmark, :is_default)
      end

      def authenticate_request
        # Add your JWT/API key authentication logic here
        head :unauthorized unless current_user
      end
    end
  end
end