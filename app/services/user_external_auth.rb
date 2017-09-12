class UserExternalAuth

  def initialize(opts = {})
    opts.each do |name, value|
      instance_variable_set("@#{name}", value)
      self.class.send(:attr_reader, name)
    end
  end

  def user
    user = User.find_by_username_or_email(login)
    return user if user
    authorize_with_consult
  end

  private

  def login
    login = @login.strip
    login = login[1..-1] if login[0] == "@"
  end

  def authorize_with_consult
    response = RestClient.post("localhost:3000/api/v1/authentication/authorize", email: login, password: password, user_type: 'auto')
    user = create_user(user_params(JSON.parse(response.body)))
    user ? user.activate : false
  rescue Exception => e
    false
  end

  def create_user(user_params)
    User.create(user_params)
  end

  def user_params(user)
    {
      name: user['name'],
      email: @login,
      password: @password,
      username: @login.split('@')[0],
      date_of_birth: user['date_of_birth'],
      ip_address: @ip_address,
      registration_ip_address: @registration_ip_address,
      locale: user_locale
    }
  end

  def user_locale
    I18n.locale
  end


end
