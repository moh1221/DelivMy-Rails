namespace :delivmy do
  desc "Delete expired authentication sessions"
  task prune_sessions: :environment do
    deleted = AuthenticationSession.where(expires_at: ...Time.current).delete_all
    puts "Removed #{deleted} expired session(s)."
  end
end
