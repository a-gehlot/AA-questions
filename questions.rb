require 'sqlite3'
require_relative 'question_database.rb'

class Questions
  attr_accessor :id, :title, :body, :author_id
  def self.all
    data = QuestionsDatabase.instance.execute("SELECT * FROM Questions")
    data.map { |datum| Questions.new(datum) }
  end

  def initialize(options)
    @id = options['id']
    @title = options['title']
    @body = options['body']
    @author_id = options['author_id']
  end

  def self.find_by_id(id)
    data = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        questions
      WHERE
        id = ?
    SQL

    return nil unless data.length > 0

    Questions.new(data.first)
  end

  def self.find_by_author_id(author_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, author_id)
      SELECT
        *
      FROM
        questions
      WHERE
        author_id = ?
    SQL

    data.map { |datum| Questions.new(datum) }
  end

  def author
    data = QuestionsDatabase.instance.execute(<<-SQL, @author_id)
      SELECT
        *
      FROM
        users
      WHERE
        id = ?
    SQL

    data.map { |datum| Users.new(datum) }
  end

  def replies
    Replies.find_by_question_id(@id)
  end

  def followers
    QuestionFollows.followers_for_question_id(@id)
  end

  def self.most_followed(n)
    QuestionFollows.most_followed_questions(n)
  end

  def likers
    QuestionLikes.likes_for_question_id(@id)
  end

  def num_likes
    QuestionLikes.num_likes_for_question_id(@id)
  end

  def self.most_liked(n)
    QuestionLikes.most_liked_questions(n)
  end

  def save
    if @id.nil?
          QuestionsDatabase.instance.execute(<<-SQL, @title, @body, @author_id)
              INSERT INTO
                  users (title, body, author_id)
              VALUES
                  (?, ?, ?)
          SQL

          @id = QuestionsDatabase.instance.last_insert_row_id
      else
          update
      end
    end

    def update
        raise "not in database" unless @id
        QuestionsDatabase.instance.execute(<<-SQL, @title, @body, @author_id, @id)
            UPDATE
                users
            SET
                title = ?, body = ?, author_id = ?
            WHERE
                id = ?
        SQL
    end

end