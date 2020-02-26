require 'sqlite3'
require_relative 'replies.rb'

class QuestionLikes
    def initialize(options)
        @id = options['id']
        @question_id = options['question_id']
        @user_id = options['user_id']
    end

    def self.find_by_id(id)
        data = QuestionsDatabase.instance.execute(<<-SQL, id)
            SELECT
                *
            FROM
                question_likes
            WHERE
                id = ?
        SQL
        return nil unless data.length > 0
        QuestionLikes.new(data.first)
    end
end