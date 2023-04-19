# frozen_string_literal: true

class ToStrable
	def to_str
		"foo"
	end
end

describe Phlex::HTML do
	extend ViewHelper

	with "hash attributes" do
		view do
			def template
				div data: { name: { first_name: "Joel" } }
			end
		end

		it "flattens the attributes" do
			expect(output).to be == %(<div data-name-first-name="Joel"></div>)
		end
	end

	with "string keyed hash attributes" do
		view do
			def template
				div data: { "name_first_name" => "Joel" }
			end
		end

		it "flattens the attributes without dasherizing them" do
			expect(output).to be == %(<div data-name_first_name="Joel"></div>)
		end
	end

	with "an array of string attributes" do
		view do
			def template
				div(class: %w(bg-red-500 rounded))
			end
		end

		it "joins the array with a space" do
			expect(output).to be == %(<div class="bg-red-500 rounded"></div>)
		end
	end

	with "an array of symbol attributes" do
		view do
			def template
				div(class: %i(bg-red-500 rounded))
			end
		end

		it "joins the array with a space" do
			expect(output).to be == %(<div class="bg-red-500 rounded"></div>)
		end
	end

	with "an array of symbol and string attributes" do
		view do
			def template
				div(class: ["bg-red-500", :rounded])
			end
		end

		it "joins the array with a space" do
			expect(output).to be == %(<div class="bg-red-500 rounded"></div>)
		end
	end

	with "a set of string attributes" do
		view do
			def template
				div(class: Set["bg-red-500", "rounded"])
			end
		end

		it "joins the array with a space" do
			expect(output).to be == %(<div class="bg-red-500 rounded"></div>)
		end
	end

	with "an object that is not a boolean, String, Symbol, Array, or Hash" do
		view do
			def template
				div(class: ToStrable.new)
			end
		end

		it "coerces the object to a string" do
			expect(output).to be == %(<div class="foo"></div>)
		end
	end

	with "an integer and a float" do
		view do
			def template
				input type: "range", min: 0, max: 10, step: 0.5
			end
		end

		it "converts the attribute values to strings" do
			expect(output).to be == %(<input type="range" min="0" max="10" step="0.5">)
		end
	end

	if RUBY_ENGINE == "ruby"
		with "unique tag attributes" do
			view do
				def template
					div class: SecureRandom.hex
				end
			end

			let :report do
				view.new.call

				MemoryProfiler.report do
					2.times { view.new.call }
				end
			end

			it "doesn't leak memory" do
				expect(report.total_retained).to be == 0
			end
		end
	end
end
