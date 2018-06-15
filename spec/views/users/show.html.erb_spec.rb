require "rails_helper"

describe "users/show.html.erb" do
  let(:user) {FactoryGirl.create :user}
  subject {user}

  it "displays user info correctly" do
    assign(:user, user)

    render

    expect(rendered).to match user.name
    expect(rendered).to match user.email
    expect(rendered).to match user.phone
    expect(rendered).to match user.address
    expect(rendered).to match user.email
    expect(rendered).to match user.city
    expect(rendered).to match user.country
    expect(response).to include edit_user_path(user)
  end
end
