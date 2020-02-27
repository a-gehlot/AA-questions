require 'sqlite3'
require_relative 'questions.rb'
require_relative 'replies.rb'

class QuestionFollows
attr_accessor :id, :user_id, :question_id

    def initialize(options)
        @id = options['id']
        @user_id = options['user_id']
        @question_id = options['question_id']
    end

    def self.find_by_id(id)
        data = QuestionsDatabase.instance.execute(<<-SQL, id)
            SELECT
                *
            FROM
                question_follows
            WHERE
                id = ?
        SQL
        
        return nil unless data.length > 0
        QuestionFollows.new(data.first)
    end

    def self.followers_for_question_id(question_id)
        data = QuestionsDatabase.instance.execute(<<-SQL, question_id)
            SELECT
                *
            FROM
                users
            JOIN
                question_follows ON users.id = question_follows.user_id
            WHERE
                question_follows.question_id = ?
        SQL

        data.map { |datum| Users.new(datum) }
    end

    def self.followed_questions_for_user_id(user_id)
        data = QuestionsDatabase.instance.execute(<<-SQL, user_id)
            SELECT
                *
            FROM
                questions
            JOIN
                question_follows ON questions.id = question_follows.question_id
            WHERE
                question_follows.user_id = ?
        SQL

        data.map { |datum| Questions.new(datum) }
    end

    def self.most_followed_questions(n)
        data = QuestionsDatabase.instance.execute(<<-SQL, n)
            SELECT
                *
            FROM
                questions
            JOIN
                question_follows ON questions.id = question_follows.question_id
            GROUP BY
                questions.id
            ORDER BY
                COUNT(*) DESC
            LIMIT
                ?
        SQL

        data.map { |datum| Questions.new(datum) }
    end


end