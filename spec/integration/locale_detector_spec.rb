require "rails_helper"

# TODO: Test with the weird q formatting or whatever
# Accept-Language: en-US,en;q=0.5

RSpec.describe "New Member Redirect" do
	def headers(locale)
    	{ HTTP_ACCEPT_LANGUAGE: locale }
	end

	before do
		SiteSetting.default_locale = "en"
		SiteSetting.allow_user_locale = true
	end

	context "accept-language header differs from their locale" do
		let(:user) { Fabricate(:user) }

		before do
			sign_in(user)
			user.update!(locale: "en")
		end

		context "never seen before" do
			before do
				user.custom_fields["locale_detector_seen"] = false
				user.save!
			end

			it "prompts the difference" do
				get "/site/locale-detector.json", headers: headers("fr")
				expect(response.status).to eq(200)
				expect(response.body).to eq('{"language":"French"}')
			end

			it "works with q-factor weighting" do
				get "/site/locale-detector.json", headers: headers("fr, en;q=0.9")
				expect(response.status).to eq(200)
				expect(response.body).to eq('{"language":"French"}')
			end
		end

		context "seen before" do
			before do
				user.custom_fields["locale_detector_seen"] = true
				user.save!
			end

			it "doesn't prompt the difference" do
				get "/site/locale-detector.json", headers: headers("fr")
				expect(response.status).to eq(200)
				expect(response.body).to eq("null")
			end
		end
	end

	context "accept-language header same as their locale" do
		let(:user) { Fabricate(:user) }

		before do
			sign_in(user)
			user.update!(locale: "fr")
		end

		context "never seen before" do
			before do
				user.custom_fields["locale_detector_seen"] = false
				user.save!
			end

			it "doesn't prompt the difference" do
				get "/site/locale-detector.json", headers: headers("fr")
				expect(response.status).to eq(200)
				expect(response.body).to eq("null")
			end
		end

		context "seen before" do
			before do
				user.custom_fields["locale_detector_seen"] = true
				user.save!
			end

			it "doesn't prompt the difference" do
				get "/site/locale-detector.json", headers: headers("fr")
				expect(response.status).to eq(200)
				expect(response.body).to eq("null")
			end
		end
	end

	context "no accept-language header" do
		let(:user) { Fabricate(:user) }

		before do
			sign_in(user)
		end

		context "never seen before" do
			before do
				user.custom_fields["locale_detector_seen"] = false
				user.save!
			end

			it "doesn't prompt the difference" do
				get "/site/locale-detector.json"
				expect(response.status).to eq(200)
				expect(response.body).to eq("null")
			end
		end
	end

	context "with a non-existing accept-language header" do
		let(:user) { Fabricate(:user) }

		before do
			sign_in(user)
		end

		context "never seen before" do
			before do
				user.custom_fields["locale_detector_seen"] = false
				user.save!
			end

			it "doesn't prompt the difference" do
				get "/site/locale-detector.json", headers: headers("doge-lang")
				expect(response.status).to eq(200)
				expect(response.body).to eq("null")
			end
		end
	end

	it "should mark the banner as seen" do
		user = Fabricate(:user)
		sign_in(user)
		expect(user.custom_fields["locale_detector_seen"]).to be_falsy
		post "/site/locale-detector.json"
		expect(response.status).to eq(200)
		user = User.find(user.id) # lol discourse
		expect(user.custom_fields["locale_detector_seen"]).to eq(true)
	end
end
