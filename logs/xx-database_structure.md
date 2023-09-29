# Database Structure

**users**/
  <user_id>/
    name: string
    username: string
    profile_image_url: string
    followers: array<string>
    following: array<string>

**tweets**/
  <tweet_id>/
    user_id: string
    text: string
    timestamp: timestamp
    likes: array<string>
    retweets: array<string>

**notifications**/
  <user_id>/
    <notification_id>/
      type: enum('like', 'retweet', 'mention')
      sender_id: string
      tweet_id: string
      timestamp: timestamp

