---
title: "Efficient Notifications in Rails: Cron vs Sidekiq vs Solid Queue"
image: "blog/isometric-office-chaos-background.jpg"
summary: "In modern web applications, timely notifications about upcoming or completed events are crucial for user engagement. Ruby on Rails offers multiple approaches to handle such background jobs, each with its own strengths and trade-offs."
tags:
- Ruby on Rails
- Cron
- Sidekiq
- Solid Queue
---

### Meeting Notifications: Typical Requirements

In an internal app used by a sales team to schedule meetings with clients, each meeting stores precise start and end times along with attendee information and time zone data. To improve punctuality and engagement, the system must send automated notifications:

- **30 minutes before the meeting** — email and push reminders,
- **10 minutes after the meeting ends** — email summaries.

Additionally, there’s a need for notifications with longer lead times:

- **48 hours before the meeting** — early reminders,
- **7 days after the meeting** — satisfaction surveys.

---

### 1. Cron Job — Simple but Less Precise

The simplest approach is to run a cron job every few minutes that queries the database for meetings needing notifications.

```ruby
# app/services/notification_service.rb
class NotificationService
  def self.send_due_notifications
    now = Time.current

    # Reminders roughly 30 minutes before the meeting
    reminder_window_start = now + 25.minutes
    reminder_window_end = now + 35.minutes
    Meeting.where(start_time: reminder_window_start..reminder_window_end).find_each do |meeting|
      NotificationMailer.reminder(meeting).deliver_later
    end

    # Follow-ups roughly 10 minutes after meeting ends
    follow_up_window_start = now - 15.minutes
    follow_up_window_end = now - 5.minutes
    Meeting.where(end_time: follow_up_window_start..follow_up_window_end).find_each do |meeting|
      NotificationMailer.follow_up(meeting).deliver_later
    end
  end
end
```

#### Pros and Cons

- **Pros:**
    - Minimal infrastructure requirements,
    - Easy to implement quickly.
- **Cons:**
    - Notifications are only as precise as the cron interval (may be delayed by several minutes),
    - Increased database load with many meetings,
    - Risk of duplicate notifications without additional safeguards.

---

### 2. Sidekiq — Precise and Scalable Background Jobs

Sidekiq enables scheduling jobs to execute at an exact time via `perform_at` or ActiveJob’s `set(wait_until:)`.

#### Example Job and Scheduling

```ruby
class MeetingNotificationJob
  include Sidekiq::Worker

  def perform(meeting_id, notification_type)
    meeting = Meeting.find_by(id: meeting_id)
    return unless meeting

    case notification_type
    when 'reminder'
      MeetingMailer.reminder(meeting).deliver_now
      # Add push notification logic here
    when 'follow_up'
      MeetingMailer.follow_up(meeting).deliver_now
    end
  end
end

# Scheduling jobs when creating or updating a meeting:
reminder_time = meeting.start_time - 30.minutes
follow_up_time = meeting.end_time + 10.minutes

MeetingNotificationJob.perform_at(reminder_time, meeting.id, 'reminder') if reminder_time > Time.current
MeetingNotificationJob.perform_at(follow_up_time, meeting.id, 'follow_up') if follow_up_time > Time.current
```

#### Important Note on Memory Usage

Sidekiq workers run persistently in memory, and while Redis efficiently stores the queued jobs, the number of scheduled jobs and especially jobs scheduled far in the future can increase memory consumption on the Sidekiq process.

- The longer the jobs remain scheduled and the larger the volume of scheduled jobs, the more memory Sidekiq may require to manage them efficiently.
- Scaling Sidekiq for high volume or long-delay jobs typically involves increasing the number of worker processes, which raises memory usage.
- Careful monitoring and tuning are essential in large-scale or long-delay scheduling scenarios to avoid excessive memory consumption.

## 3. Solid Queue — Rails 8 Built-in Database-backed Queue

Solid Queue is a database-backed job queue designed to simplify background job processing without adding external dependencies. This design brings clear, practical advantages for your project:

### Key Project Benefits:

- **Reduced Operational Complexity:**

    No need to install, configure, and maintain an additional Redis server or other queue services. This means fewer moving parts, less infrastructure to monitor, and less risk of downtime due to external service failure.

- **Transactional Integrity:**

    Jobs are enqueued within the same database transaction as your business logic. This ensures **atomicity** — if your transaction rolls back, the job won’t be enqueued, preventing out-of-sync states between your app and job queue.

- **Easier Debugging and Transparency:**

    Since all jobs are stored in your primary database, developers and operations teams can directly query job tables, track job statuses, and debug failed jobs using familiar tools — no need to connect to separate systems or specialized dashboards.

- **Simplified Deployment and Scalability for Small to Medium Projects:**

    Deploying your app becomes easier because you only manage one data store. For many projects, this reduces the barrier to adding background processing and helps maintain a smaller infrastructure footprint.

- **Immediate Productivity Boost:**

    Developers can start implementing background jobs quickly without waiting for infrastructure approval or setup, speeding up feature delivery.


### How Scheduling Works in Solid Queue

- When calling `set(wait_until: time).perform_later(...)`, the job is saved in a database table along with the scheduled execution time,
- Rails workers periodically query the database for jobs due to run,
- Jobs are executed in the application context,
- Jobs remain persisted in the database across restarts, ensuring reliability,
- Database locking and transactions prevent duplicate execution and race conditions.

### Implementation Example

```ruby
class MeetingNotificationJob < ApplicationJob
  queue_as :default

  def perform(meeting_id, notification_type)
    meeting = Meeting.find_by(id: meeting_id)
    return unless meeting

    case notification_type
    when 'reminder'
      MeetingMailer.reminder(meeting).deliver_now
    when 'follow_up'
      MeetingMailer.follow_up(meeting).deliver_now
    end
  end
end

class Meeting < ApplicationRecord
  after_commit :schedule_notifications, on: [:create, :update]

  def schedule_notifications
    now = Time.current
    reminder_time = start_time - 30.minutes
    follow_up_time = end_time + 10.minutes

    MeetingNotificationJob.set(wait_until: reminder_time).perform_later(id, 'reminder') if reminder_time > now
    MeetingNotificationJob.set(wait_until: follow_up_time).perform_later(id, 'follow_up') if follow_up_time > now
  end
end
```

### Extended Example: Notifications with Longer Lead Times

For cases needing notifications well in advance or long after the meeting:

- **48 hours before the meeting** — early reminders,
- **7 days after the meeting** — satisfaction surveys.

### Notes on Long-Interval Notifications and Sidekiq
Sidekiq stores jobs in Redis, which is an in-memory database. This provides very fast access to queued jobs and works excellently for short delays or jobs executed almost immediately.

However, in scenarios where notifications need to be sent far in advance (e.g., 48 hours before a meeting) or long after an event (e.g., 7 days after a meeting), Sidekiq must keep these jobs in Redis memory for the entire waiting period.

This means that each job scheduled hours or days ahead occupies RAM space continuously, which, when scaled to many such long-delayed jobs, can lead to significant memory consumption and degrade overall system performance.

### Why Storing Jobs in the Database Is Better for Long Delays
An alternative approach is to use a database-backed job queue that stores jobs on disk rather than in RAM. This way, long-waiting jobs do not consume precious memory resources and are only loaded when it’s time to execute them.

For example, Active Job with a database adapter (like Delayed Job, Que, or a custom solution) allows you to schedule jobs inside the database, optimized for storing large numbers of records over long periods. Instead of holding them in memory, the jobs are simply queried and run at their scheduled time.

### Summary and Recommendations

| Approach | Precision | Memory Usage | Scalability | Infrastructure Requirements | Notes |
| --- | --- | --- | --- | --- | --- |
| Cron Job | Low | Minimal | Limited | None | Easy to set up but less precise |
| Sidekiq | Very High | Moderate | Very High | Redis + Worker Processes + RAM | Great for large scale, requires resources |
| Solid Queue | High | Low to Moderate | Good | Database + Rails Workers | Native Rails 8 support, minimal infra |

For most Rails 8 projects with moderate scale, **Solid Queue** offers an excellent balance of precision, reliability, and simplicity without extra dependencies. As load grows, Sidekiq can be integrated for greater scalability and monitoring features.
