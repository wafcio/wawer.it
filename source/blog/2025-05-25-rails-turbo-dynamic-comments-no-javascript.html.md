---
title: "Building Dynamic Comments in Rails With Turbo Drive, Frames, and Streams - No JavaScript Needed"
image: "blog/dynamic-comments.jpg"
summary: "Heavy frontend JavaScript frameworks like React, Vue, or Angular have long dominated modern web development. While powerful, these tools often come with significant complexity, steep learning curves, and a growing separation between frontend and backend teams. But what if you could build dynamic, real-time web applications without writing a single line of JavaScript?"
tags:
- Ruby on Rails
- Turbo Drive
- Turbo Frames
- Turbo Streams
---

Enter **Hotwire** - short for **HTML Over The Wire** - a bold, server-driven approach introduced by [Basecamp](https://basecamp.com/) (the creators of Ruby on Rails) that reimagines how interactivity can be handled on the web. Instead of sending JSON APIs to a frontend framework, Hotwire sends HTML directly from the server in response to user interactions. This allows developers to keep their application logic, rendering, and state management on the server - where Ruby on Rails shines - while still providing a snappy and interactive experience in the browser.

At the core of Hotwire is **Turbo**, which is composed of three powerful tools:

- **Turbo Drive** – enhances traditional navigation by automatically replacing full page reloads with partial updates.
- **Turbo Frames** – allow you to isolate parts of the page for targeted updates, such as submitting a form or replacing a modal.
- **Turbo Streams** enables live, real-time updates to the page via WebSockets or server-sent events without writing custom JS.

Combined, these tools allow Rails developers to build responsive, interactive applications with the simplicity and elegance that Rails is known for - all while avoiding the frontend complexity that modern SPAs (single-page applications) often require.

This article’ll demonstrate how to build a **dynamic, live-updating comment section** for a blog post using Hotwire’s Turbo stack. You'll learn how to:

- Set up models and controllers for comments
- Submit forms without full page reloads
- Broadcast new comments in real-time to all connected users
- Achieve all of this using **only Rails, Turbo, and server-rendered HTML - no JavaScript required**

Whether you're new to Hotwire or looking to see it in action with a real-world feature, this hands-on guide will walk you through each step and show you the magic of building modern UI the Rails way.

### Use Case: Live-Updating Comment Section

Imagine a classic blog application - each post has a dedicated page where users can read the article and engage by leaving comments. This comment section is a perfect candidate for a dynamic interface: users expect new comments to appear instantly, without needing to refresh the page or click a “Load more” button.

Here’s what we want to build:

- When a user submits a new comment, it should appear immediately below the post - **without a full page reload**.
- Comments from **other users** should also appear in real time, giving a sense of a living, interactive discussion.
- The experience should feel fast and seamless - like a modern JavaScript-rich frontend - but we’ll rely entirely on **Rails and Hotwire** to make it happen.

In short, we’re aiming to deliver a user experience similar to what you’d expect from a real-time chat or comment feed on social media - but using nothing more than traditional Rails views, controllers, and partials, powered by **Turbo Drive**, **Turbo Frames**, and **Turbo Streams**.

This use case is ideal for demonstrating Hotwire’s power. It combines several key features:

- **Turbo Drive** will handle smooth page transitions and form submissions.
- **Turbo Frames** will isolate the comment form and allow it to update independently.
- **Turbo Streams** will push new comments to all connected clients in real time using **ActionCable** under the hood.

By the end of this article, you’ll have a dynamic, real-time comment section that feels modern and snappy - yet is simple to maintain and doesn’t require managing a JavaScript frontend stack.

This is the Rails way it was meant to be: full-stack, productive, and delightfully minimal.

### Setup: Models and Controllers

Before adding interactivity with Turbo, we must set up our data models and routes. In this step, we’ll create a basic blog with posts and comments and prepare the backend structure that will power our dynamic comment section.

#### Step 1: Generate Post and Comment Resources

Let’s start by generating a scaffold for blog posts and a model for comments:

```bash
rails g scaffold Post title:string body:text
rails g model Comment post:references content:text
```

The `Post` scaffold gives us a full set of RESTful actions, views, and forms to quickly create and display blog posts. The `Comment` model is tied to a post via a `post_id` foreign key, and we’ll build the interface for managing comments shortly.

#### Step 2: Migrate the Database

After generating the models, apply the migrations to create the corresponding database tables:

```bash
rails db:migrate
```

#### Step 3: Define Associations

Next, we connect the models so Rails understands the relationship between posts and comments.

`app/models/post.rb`

```ruby
class Post < ApplicationRecord
  has_many :comments, dependent: :destroy
end
```

Each post can have many comments. The `dependent: :destroy` option ensures that when a post is deleted, its associated comments are removed as well.

`app/models/comment.rb`

```ruby
class Comment < ApplicationRecord
  belongs_to :post
end
```

This is where **Hotwire** starts to shine. The `broadcasts_to :post` line is all it takes to enable **Turbo Streams broadcasting**. Whenever a comment is created, updated, or destroyed, Turbo will automatically broadcast changes to any connected clients subscribed to that post’s stream. We’ll make use of this later.

### Step 4: Generate Comments Controller

Now, we’ll create a dedicated controller to handle comment creation:

```bash
rails g controller Comments
```

This will generate a new `CommentsController` where we’ll define logic for submitting comments and rendering responses via Turbo Streams.

Finally, let’s update our routes to include nested comments under posts.

`config/routes.rb`

```ruby
Rails.application.routes.draw do
  resources :posts do
    resources :comments, only: [:create]
  end
  root "posts#index"
end
```

With this setup, each comment will be tied to a specific post via a nested route like:

```
POST /posts/:post_id/comments
```

We now have everything in place to begin enhancing the UI with Turbo features: smooth form submissions, dynamic comment rendering, and real-time updates - all without writing a line of custom JavaScript.

### Turbo Drive - The Baseline for Interactivity

Before diving into Turbo Frames and Streams, let’s begin with the simplest and most fundamental part of Hotwire: **Turbo Drive**.

Turbo Drive is **enabled by default** in new Rails apps. It intercepts standard navigation and form submissions to make them feel much faster and smoother. Instead of full page reloads, it performs the request in the background and **replaces only the `<body>` tag**, preserving page layout and minimizing disruption.

#### Why It Matters

This approach alone can dramatically improve the feel of your Rails app:

- Navigation feels snappier, like a single-page application.
- Forms are submitted in the background, with seamless redirects.
- No need for manual `remote: true` or JavaScript handlers.

Even with no extra work, your app already feels more dynamic.

But we can go further. Let’s build out the post show page with full comment management - adding, editing, and deleting comments - and see how Turbo Drive handles it out of the box.

#### Post Show Page With Comment Features

We’ll start with rendering the blog post and its comments. Then we’ll layer in **creation**, **editing**, and **deletion** actions - all using regular Rails helpers and Turbo Drive.

`app/controllers/comments_controller.rb`

```ruby
def create
  @post = Post.find(params[:post_id])
  @comment = @post.comments.build(comment_params)

  if @comment.save
    redirect_to @post, notice: "Comment was successfully created."
  else
    render "posts/show", status: :unprocessable_entity
  end
end
```

`app/views/posts/show.html.erb`

```erb
<h1><%= @post.title %></h1>
<p><%= @post.body %></p>

<hr>

<h2>Comments</h2>
<div id="comments">
  <%= render @post.comments %>
</div>

<h3>Add a Comment</h3>
<%= render "comments/form", post: @post, comment: Comment.new %>
```

`app/views/comments/_comment.html.erb`

```erb
<div id="comment_<%= comment.id %>">
  <p><%= comment.content %></p>

  <small>
    <%= link_to "Edit", edit_post_comment_path(comment.post, comment) %> |
    <%= link_to "Delete", post_comment_path(comment.post, comment), method: :delete, data: { turbo_confirm: "Are you sure?" } %>
  </small>
</div>
```

`app/views/comments/_form.html.erb`

```erb
<%= form_with(model: [post, comment]) do |form| %>
  <div>
    <%= form.label :content, "Your Comment" %><br>
    <%= form.text_area :content, rows: 3, required: true %>
  </div>

  <div>
    <%= form.submit comment.persisted? ? "Update Comment" : "Post Comment" %>
  </div>
<% end %>
```

#### Edit and Update Comments

To support editing, add the `edit` and `update` actions in your `CommentsController`:

```ruby
def edit
  @post = Post.find(params[:post_id])
  @comment = @post.comments.find(params[:id])
end

def update
  @post = Post.find(params[:post_id])
  @comment = @post.comments.find(params[:id])

  if @comment.update(comment_params)
    redirect_to @post, notice: "Comment updated."
  else
    render :edit, status: :unprocessable_entity
  end
end
```

And the `edit` view:

`app/views/comments/edit.html.erb`

```erb
<h3>Edit Comment</h3>
<%= render 'comments/form', post: @post, comment: @comment %>
```

Turbo Drive will handle this redirect after a successful update by replacing the page body without a full reload - giving a seamless editing experience.

#### Delete Comments - Fixing Prefetch Issues

For deletion, Turbo Drive generally handles `method: :delete` just fine - **except when combined with `link_to` and prefetching**.

##### The Problem: Prefetching

Turbo Drive **prefetches links on hover**, which can **accidentally trigger a `DELETE` request** if `method: :delete` is misused or JavaScript is disabled. To avoid this, it’s recommended to **use a `button_to` for destructive actions** like deletion.

##### The Fix: `button_to` for Deletes

Replace the `link_to` delete with `button_to`:

```erb
<%= button_to "Delete", post_comment_path(comment.post, comment),
              method: :delete,
              data: { turbo_confirm: "Are you sure?" },
              form: { style: "display:inline" } %>
```

This change ensures the action is wrapped in a proper form, bypasses Turbo's link prefetching, and remains safe and predictable across all browsers.

So far, with **just Turbo Drive**, we’ve achieved:

- Fast, background-driven page loads and form submissions.
- Seamless comment creation, editing, and deletion.
- No custom JavaScript needed.

But there’s more we can do.

- Submitting a comment still reloads the full `<body>`, which can cause layout jumps and unnecessary re-rendering.
- Comments added by other users **don’t appear automatically** - you’d need to refresh to see them.

To solve these, we’ll next introduce **Turbo Frames** for fine-grained updates, and **Turbo Streams** for real-time broadcasting - taking us even closer to a modern interactive experience, built the Rails way.

### Turbo Stream - Broadcast Comments Live

Let’s walk through how to make **new comments appear instantly** for all users currently viewing the post - without any page reloads, and without writing JavaScript.

#### Step 1: Ensure Broadcasts Are Enabled in the Model

This is the key line that enables real-time broadcasting via Turbo Streams:

Now that we have a working comment form and a basic dynamic experience thanks to **Turbo Drive**, let’s take it one step further with **Turbo Frames**.

#### Why Turbo Frames?

While Turbo Drive intercepts page-wide navigation and form submissions, it still replaces the entire `<body>` of the page on redirects. This can cause jarring visual effects, such as scroll jumps or flickering, especially when only a small portion of the page needs updating.

This is where **Turbo Frames** shine.

A **Turbo Frame** allows us to isolate a specific page section, like a form or a comment list, and update *just that fragment* upon user interaction. Instead of reloading the whole page, Turbo will replace *only the content within the frame*.

This is perfect for our use case: submitting a new comment and showing the updated form (or any validation errors) in place, without touching the rest of the page.

#### Wrapping the Comment Form in a Turbo Frame

We’ll start by wrapping our comment form partial in a `turbo_frame_tag`. This tells Turbo to scope any updates to this portion of the DOM.

`app/models/comment.rb`

```ruby
class Comment < ApplicationRecord
  belongs_to :post
  broadcasts_to :post
end
```

Rails will automatically look for Turbo Stream templates (like `create.turbo_stream.erb`) and broadcast the result to any connected clients.

#### Step 2: Subscribe to the Stream in the Post View

Make sure your `show` view subscribes to Turbo Streams for this post.

`app/views/posts/show.html.erb`

```erb
<%= turbo_stream_from @post %>
```

This enables the browser to receive real-time updates for anything broadcast to the `@post`.

#### Step 3: Wrap the Comments List with an ID Target

Turbo Streams need a target to insert new comments into. Add a wrapper with a matching `id`.

`app/views/posts/show.html.erb`

```erb
<div id="comments">
  <%= render @post.comments %>
</div>
```

This allows us to use `append "comments"` as the Turbo Stream target.

#### Step 4: Set Up the Comment Form

Use `turbo_frame_tag` around your form so it can be updated independently (e.g., after submission).

`app/views/comments/_form.html.erb`

```erb
<%= turbo_frame_tag "new_comment" do %>
  <%= form_with model: [post, comment], local: false do |f| %>
    <div>
      <%= f.text_area :content, rows: 3, placeholder: "Write a comment..." %>
    </div>
    <div>
      <%= f.submit "Post Comment" %>
    </div>
  <% end %>
<% end %>
```

Use this partial in the post `show` page:

```erb
<h3>Add a Comment</h3>
<%= render "comments/form", post: @post, comment: Comment.new %>
```

#### Step 5: Handle Comment Creation in Controller

Define the `create` action in your `CommentsController`:

`app/controllers/comments_controller.rb`

```ruby
def create
  @post = Post.find(params[:post_id])
  @comment = @post.comments.build(comment_params)

  if @comment.save
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @post }
    end
  else
    render :new
  end
end

private

def comment_params
  params.require(:comment).permit(:content)
end
```

#### Step 6: Add Turbo Stream Template for Creation

This template will render when a comment is successfully created.

`app/views/comments/create.turbo_stream.erb`

```erb
<%= turbo_stream.append "comments", partial: "comments/comment", locals: { comment: @comment } %>
<%= turbo_stream.replace "new_comment", partial: "comments/form", locals: { post: @post, comment: Comment.new } %>

```

What’s happening here:

- The new comment is appended to the comment list.
- The form is reset by replacing the `"new_comment"` frame.

#### Step 7: Define the Comment Partial

Finally, make sure you have a comment partial for rendering each comment.

`app/views/comments/_comment.html.erb`

```erb
<%= turbo_frame_tag dom_id(comment) do %>
  <div id="<%= dom_id(comment, :content) %>">
    <p><%= comment.content %></p>
    <%= link_to "Edit", edit_post_comment_path(comment.post, comment), data: { turbo_frame: dom_id(comment) } %>
    <%= link_to "Delete", post_comment_path(comment.post, comment), method: :delete, data: { turbo_confirm: "Are you sure?" } %>
  </div>
<% end %>
```

With these steps, new comments will appear in real time for all users - and your form stays responsive and reset automatically. No page reloads. No flickers. No JavaScript.

#### Update Comments in Real Time

Let’s allow users to edit their comments and have those changes instantly reflected for everyone viewing the post.

#### Step 1: Add Edit and Update Actions

First, enable comment editing in the controller:

`app/controllers/comments_controller.rb`

```ruby
def edit
  @comment = Comment.find(params[:id])
end

def update
  @comment = Comment.find(params[:id])
  if @comment.update(comment_params)
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @comment.post }
    end
  else
    render :edit
  end
end
```

Make sure `comment_params` is already defined.

#### Step 2: Add Edit Form

Create an editable form partial:

`app/views/comments/_form.html.erb` (shared with create & update)

```erb
<%= turbo_frame_tag dom_id(comment) do %>
  <%= form_with model: [comment.post, comment], local: false do |f| %>
    <div>
      <%= f.text_area :content, rows: 3 %>
    </div>
    <div>
      <%= f.submit comment.persisted? ? "Update Comment" : "Post Comment" %>
    </div>
  <% end %>
<% end %>
```

#### Step 3: Add Edit Button and Frame Target

In the comment partial:

`app/views/comments/_comment.html.erb`

```erb
<%= turbo_frame_tag dom_id(comment) do %>
  <div id="<%= dom_id(comment, :content) %>">
    <p><%= comment.content %></p>
    <%= link_to "Edit", edit_post_comment_path(comment.post, comment), data: { turbo_frame: dom_id(comment) } %>
  </div>
<% end %>
```

This ensures the edit form loads into the comment frame in-place.

#### Step 4: Turbo Stream Response for Update

`app/views/comments/update.turbo_stream.erb`

```erb
<%= turbo_stream.replace @comment %>
```

Done! When a comment is edited and saved, all clients subscribed to the post will see the updated version instantly.

#### Delete Comments in Real Time

Let’s add support for live comment deletion via Turbo Streams.

#### Step 1: Add Destroy Action

Update your controller:

`app/controllers/comments_controller.rb`

```ruby
def destroy
  @comment = Comment.find(params[:id])
  @comment.destroy
  respond_to do |format|
    format.turbo_stream
    format.html { redirect_to @comment.post }
  end
end
```

#### Step 2: Add Delete Button

Update the comment partial to include a delete link:

`app/views/comments/_comment.html.erb`

```erb
<%= turbo_frame_tag dom_id(comment) do %>
  <div id="<%= dom_id(comment, :content) %>">
    <p><%= comment.content %></p>
    <%= link_to "Edit", edit_post_comment_path(comment.post, comment), data: { turbo_frame: dom_id(comment) } %>
    <%= link_to "Delete", post_comment_path(comment.post, comment), method: :delete, data: { turbo_confirm: "Are you sure?", turbo: false } %>
  </div>
<% end %>

```

#### Step 3: Turbo Stream Template for Deletion

`app/views/comments/destroy.turbo_stream.erb`

```erb
<%= turbo_stream.remove @comment %>
```

Now, when a comment is deleted:

- It is immediately removed from the DOM
- The change is broadcast to all users viewing the post in real time

### Final Effect

At this point, our real-time comment system is complete - and the results are both powerful and delightfully simple:

- **New comments appear instantly** below the post after submission - **without a full page reload**.
- **The form resets automatically**, thanks to the `turbo_frame_tag` wrapping and Turbo Stream response.
- **All other users viewing the same post page** see the new comment appear **live in real time**, courtesy of Turbo’s broadcast system and ActionCable.

This final setup provides an experience that rivals modern SPA frontends - without touching JavaScript or managing complex state in the browser.

### Bonus: Visualizing the Real-Time Magic

To truly appreciate the final effect, try capturing a short GIF or screen recording that shows:

1. **Two browser windows** open side by side, both displaying the same blog post.
2. In one window, a user types and submits a new comment.
3. The comment **immediately appears in both windows**, without a refresh or interaction in the second window.

This live feedback loop demonstrates the seamless power of Hotwire - real-time updates with only Rails, HTML, and a sprinkle of ActionCable.

### Bonus: What If JS Is Disabled?

While Hotwire empowers Rails apps with dynamic, real-time interactivity - it still relies on JavaScript behind the scenes. That means if a user visits your app with **JavaScript disabled**, certain features won’t function the same way.

Here’s what happens when JavaScript is turned off:

- **Turbo Drive** won’t intercept links or form submissions - all navigation and form actions fall back to **full page reloads**.
- **Turbo Frames** won’t isolate form or partial updates - forms will **refresh the entire page**, and validation errors will render in full views.
- **Turbo Streams** won’t receive or apply real-time updates - **ActionCable won’t connect**, and live comment broadcasting stops working.

But the good news?

**Hotwire degrades gracefully**. Rails still processes the request, renders the appropriate HTML, and returns a fully functional page. Nothing breaks - users can still read posts, submit comments, and interact with the app, just with less fluidity.

### Pro Tips for Enhancing the Fallback UX

If you want to make the experience more intentional for users without JavaScript, consider these enhancements:

- **Use `<noscript>` tags** to show a polite message or warning, such as:

    ```html
    <noscript>
      <div class="alert alert-warning">
        For the best experience, please enable JavaScript. Real-time updates and enhanced navigation require it.
      </div>
    </noscript>
    ```

- **Design forms and views to work without Turbo** - by ensuring standard Rails behaviors (redirects, validations, error messages) are still handled well outside of Turbo contexts.
- **Add conditional logic** to skip Turbo-specific tags or features if needed - though this is rarely necessary unless you’re deeply customizing interactions.

Even without JavaScript, your Rails app remains functional, stable, and accessible. But with Hotwire fully enabled, you unlock the seamless, modern experience your users will love - all with a minimalist stack and no frontend complexity.

### Conclusion

By combining **Turbo Drive**, **Turbo Frames**, and **Turbo Streams**, we’ve built a fully functional, real-time comment system that feels modern - yet required **no custom JavaScript**.

From smooth form submissions and isolated updates to live broadcasts across clients, this approach proves that Rails can deliver powerful interactivity without the complexity of a heavy frontend framework.

And this is just the beginning.

The same building blocks can power:

- **Live notifications**
- **Inline editing**
- **Real-time likes or reactions**
- **Instant search and filters**
- **Interactive dashboards**

All with server-rendered HTML, real-time updates via ActionCable, and clean, maintainable Rails code.

Hotwire is reshaping how Rails developers think about frontend interactivity - keeping your application logic on the server, reducing context switching, and embracing a productivity-first mindset.

So go ahead: explore, experiment, and build the modern web **the Rails way** - delightfully minimal, impressively fast, and fully dynamic.

Happy coding!
