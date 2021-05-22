module ErrorResponse
  def bad_request(resource)
    {
      code: 400,
      messages: resource.errors.full_messages,
    }
  end

  def invalid_token
    {
      code: 401,
      messages: ['認証トークンの形式が無効です'],
    }
  end

  def invalid_password
    {
      code: 401,
      messages: ['パスワードが誤っています'],
    }
  end

  def forbidden
    {
      code: 403,
      messages: ['リソースへのアクセスが禁止されています'],
    }
  end

  def resource_not_found
    {
      code: 404,
      messages: ['リソースが見つかりません'],
    }
  end

  def internal_server_error
    {
      code: 500,
      messages: ['内部エラーが発生しました'],
    }
  end
end
