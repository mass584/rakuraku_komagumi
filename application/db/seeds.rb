Room.create(
  id: 1,
  name: 'サンプル教室',
  email: 'sample@sample.com',
  password_digest: ApplicationRecord.digest('password')
)
