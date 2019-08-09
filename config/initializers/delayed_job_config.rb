# frozen_string_literal: true

Delayed::Worker.delay_jobs = !Rails.env.test?
