desc "Fill the database tables with some sample data"
task sample_data: :environment do
  p "Creating sample data"

  if Rails.env.development?
    FollowRequest.destroy_all
    Comment.destroy_all
    Like.destroy_all
    Photo.destroy_all
    User.destroy_all
  end

  usernames = (1..10).map { Faker::Internet.unique.username }
  usernames << "alice"
  usernames << "bob"

  usernames.each do |username|
    User.create(
      email: "#{username}@example.com",
      password: "password",
      username: username.downcase,
      private: [true, false].sample,
    )
  end

  p "There are now #{User.count} users."

  users = User.all
  alice = User.find_by({ :username => "alice" })
  bob = User.find_by({ :username => "bob" })

  users.each do |first_user|
    users.each do |second_user|
      next if first_user == second_user
      if rand < 0.75
        first_user.sent_follow_requests.create(
          { :recipient => second_user, :status => "accepted" }
        )
      end
    end
  end

  # Ensure Alice and Bob follow each other
  alice.sent_follow_requests.create({ :recipient => bob, :status => "accepted" })
  bob.sent_follow_requests.create({ :recipient => alice, :status => "accepted" })

  p "There are now #{FollowRequest.count} follow requests."

  users.each do |user|
    rand(5..15).times do
      photo = user.own_photos.create(
        caption: Faker::Lorem.sentence,
        image: Faker::LoremFlickr.image,
      )

      user.followers.each do |follower|
        if rand < 0.5 && !photo.fans.include?(follower)
          photo.fans << follower
        end

        if rand < 0.25
          photo.comments.create(
            body: Faker::Quote.famous_last_words,
            author: follower,
          )
        end
      end
    end
  end
  
  p "There are now #{Photo.count} photos."
  p "There are now #{Like.count} likes."
  p "There are now #{Comment.count} comments."
end
