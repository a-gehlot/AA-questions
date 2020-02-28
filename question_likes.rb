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

    def self.likes_for_question_id(question_id)
        data = QuestionsDatabase.instance.execute(<<-SQL, question_id)
            SELECT
                *
            FROM
                users
            JOIN
                question_likes ON users.id = question_likes.user_id
            WHERE
                question_likes.question_id = ?
        SQL

        data.map { |datum| Users.new(datum) }
    end

    def self.num_likes_for_question_id(question_id)
        data = QuestionsDatabase.instance.execute(<<-SQL, question_id)
            SELECT
                COUNT(*) AS likes
            FROM
                questions
            JOIN
                question_likes ON questions.id = question_likes.question_id
            WHERE
                questions.id = ?
        SQL
    end

    def self.liked_questions_for_user_id(user_id)
        data = QuestionsDatabase.instance.execute(<<-SQL, user_id)
            SELECT
                *
            FROM
                questions
            JOIN
                question_likes ON questions.id = question_likes.question_id
            WHERE
                question_likes.user_id = ?
        SQL

        data.map { |datum| Questions.new(datum) }
    end

    def self.most_liked_questions(n)
        data = QuestionsDatabase.instance.execute(<<-SQL, n)
            SELECT
                *
            FROM
                questions
            JOIN
                question_likes ON questions.id = question_likes.question_id
            GROUP BY
                questions.id
            ORDER BY
                COUNT(*)
            LIMIT
                ?
        SQL
    end
            


end