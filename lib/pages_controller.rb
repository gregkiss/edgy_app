class APP_CAMEL::PagesController < ApplicationController
  
  def contact_form
    @contact = Contact.new(contact_params)
    @contact.save
    GeneralMailer.contact(@contact.id, "team@theedgeworkshop.com",
							"New Message On DOMAIN_NAME", "New Message On DOMAIN_NAME").deliver
    flash[:thanks] = "true"
    redirect_to APP_NAME_contact_path
  end
  
  private
  
    def contact_params
      params.require(:contact).permit(:name, :contact_info, :subject, :text, :app)
    end
end
