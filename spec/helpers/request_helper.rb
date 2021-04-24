module RequestHelper
  def login user
    post v1_login_path, params: {auth: { email: user.email, password: user.password }}.to_json, headers: { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
  end

  def get_auth_header response
    return {"Authorization": "Bearer #{JSON.parse(response.body)["token"]}"}
  end
end
