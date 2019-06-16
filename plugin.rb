# name: locale-detector
# version: 1.0.1
# authors: boyned/Kampfkarren

after_initialize do
	require_dependency "locale_site_setting"

	module ::LocaleDetector
		class Engine < ::Rails::Engine
			engine_name "locale_detector"
			isolate_namespace LocaleDetector
		end
	end

	User.register_custom_field_type("locale_detector_seen", :boolean)

	class LocaleDetector::LocaleDetectorController < ::ApplicationController
		def get
			if current_user && !current_user.custom_fields["locale_detector_seen"]
				accept_language = request.headers["HTTP_ACCEPT_LANGUAGE"]
				if accept_language.present?
					locale = current_user.effective_locale
					accept_language.gsub(/\s+/, "").gsub(/;q=[^,]+/, "").split(",").each do |accept_language|
						if locale != accept_language && LocaleSiteSetting.supported_locales.include?(accept_language)
							return render json: {language: LocaleSiteSetting.language_names[accept_language]["name"]}
						end
					end
				end
			end

			render json: nil
		end

		def seen
			if current_user
				current_user.custom_fields["locale_detector_seen"] = true
				current_user.save
				current_user.reload
			end

			render json: success_json
		end
	end

	LocaleDetector::Engine.routes.draw do
		get "/locale-detector" => "locale_detector#get"
		post "/locale-detector" => "locale_detector#seen"
	end

	Discourse::Application.routes.append do
		mount ::LocaleDetector::Engine, at: "/site"
	end
end
