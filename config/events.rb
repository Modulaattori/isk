WebsocketRails::EventMap.describe do
  # You can use this file to map incoming events to controller actions.
  # One event can be mapped to any number of controller actions. The
  # actions will be executed in the order they were subscribed.
  #
  # Uncomment and edit the next line to handle the client connected event:


  #subscribe :client_connected, :to => Sockets::, :with_method => :method_name


  #
  # Here is an example of mapping namespaced events:
  #   namespace :product do
  #     subscribe :new, :to => ProductController, :with_method => :new_product
  #   end
  # The above will handle an event triggered on the client like `product.new`.

	namespace :svg do
		# Create a new svg from suplied data using the SimpeSlide.create_svg method
		# data = {
		# 	simple: {
		# 		heading: 'Slide heading',
		# 		text: 'Slide contents...',
		#  		color: Red,   # hilight color
		# 		text_size: 72,
		#     text_align: 'left' # left, right or centered
		# 	}
		# }
		subscribe :simple,				to: SvgController, with_method: :simple
	end


  namespace :iskdpy do
    #Näytin esittäytyy ja saa alkutietonsa
    #data = {:display_name}
    #palauttaa success, data = {näyttimen serialisaatio}
    subscribe :hello,         to: IskdpyController, with_method: :hello
    
    #Näytin kertoo mitä kelmua näytetään parhaillaan.
    #data = {display_id, group_id, slide_id} 
    # TAI
    # data = {display_id, override_queue_id}
    #palauttaa: display_<id> kanavalle viestin "current_slide" data={group_id, slide_id}
    subscribe :current_slide,         to: IskdpyController, with_method: :current_slide
    
    #Käli ja näytin viestivät keskenään kalvojen vaihdosta
    #data = {display_id, mitätahansamuuta}
    #palauttaa: display_<id> kanavalle goto_slide eventin jonka data on sama kuin sisääntullut
    subscribe :goto_slide,            to: IskdpyController, with_method: :goto_slide
    
    #Näytin kertoo kun override on näytetty.
    #data = {display_id, override_queue_id}
    #palauttaa: display_<id> kanavalle viestin "override_shown" data={display_id, override_id}
    subscribe :override_shown,        to: IskdpyController, with_method: :override_shown
    
    #Pyydetään näyttimen tiedot serialisoituna
    #data = {display_id}
    #palauttaa: display_<id> kanavalle viestin "data" data={näyttimen serialisaatio}
    subscribe :display_data,          to: IskdpyController, with_method: :display_data
    
    subscribe :current_presentation,  to: IskdpyController, with_method: :current_presentation
    
  end


end
