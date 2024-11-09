# Patches Redmine's Users dynamically.
module OauthProviderUserPatch
  def self.included(base) # :nodoc:
    base.class_eval do
      unloadable

      has_many :client_applications
      has_many :tokens, -> {includes(:client_application).order("authorized_at desc")}, class_name: "OauthToken"
    end
  end
end
