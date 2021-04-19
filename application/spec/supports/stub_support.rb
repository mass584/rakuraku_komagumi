module StubSupport
  def stub_authenticate_user
    allow_any_instance_of(ApplicationController).to receive(:authenticate_user!)
  end

  def stub_current_room(room)
    allow_any_instance_of(ApplicationController).to receive(:current_room).and_return(room)
  end

  def stub_current_term(term)
    allow_any_instance_of(ApplicationController).to receive(:current_term).and_return(term)
  end
end
