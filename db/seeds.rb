User.create!([
  {email: "adrie.donker@gmail.com", encrypted_password: "$2a$11$UNDfmGaJESUbIYxl2pAlducQOKzT9HXhO2jVPuB19yjjdfU..rEUe", reset_password_token: nil, reset_password_sent_at: nil, remember_created_at: nil, sign_in_count: 41, current_sign_in_at: "2016-08-16 13:10:29", last_sign_in_at: "2016-08-15 19:54:03", current_sign_in_ip: "94.215.220.66", last_sign_in_ip: "94.215.220.66", name: "Adrie Donker", role: "admin", locale: "nl"},
  {email: "geerta@donker.biz", encrypted_password: "$2a$11$tjyMTQ.az6uFSZMVZTcc0OCUXWel8uwLssGW1ncg9HEhIZYnAnLp2", reset_password_token: nil, reset_password_sent_at: nil, remember_created_at: nil, sign_in_count: 2, current_sign_in_at: "2016-08-15 18:38:09", last_sign_in_at: "2016-08-14 19:02:50", current_sign_in_ip: "94.215.220.66", last_sign_in_ip: "94.215.220.66", name: "Geerta", role: "user", locale: "nl"},
  {email: "thomas@google.com", encrypted_password: "$2a$11$EKHvKY7C1.EwKYNZXP4cqON1ko7YQiFRZ2uHQPDeStG7govIlrsKW", reset_password_token: nil, reset_password_sent_at: nil, remember_created_at: nil, sign_in_count: 1, current_sign_in_at: "2016-08-14 19:04:03", last_sign_in_at: "2016-08-14 19:04:03", current_sign_in_ip: "94.215.220.66", last_sign_in_ip: "94.215.220.66", name: "Thomas", role: "user", locale: nil},
  {email: "silviadonker@gmail.com", encrypted_password: "$2a$11$y2aZ90ex68AtIeICQfzaJ.jSFaJBequxQMt3LiOtjhHt9wr95Qslm", reset_password_token: nil, reset_password_sent_at: nil, remember_created_at: nil, sign_in_count: 1, current_sign_in_at: "2016-08-14 19:04:37", last_sign_in_at: "2016-08-14 19:04:37", current_sign_in_ip: "94.215.220.66", last_sign_in_ip: "94.215.220.66", name: "Silvia", role: "user", locale: "nl"},
  {email: "diondonker@gmail.com", encrypted_password: "$2a$11$io25bRbF140lmBD63aXuG.uF3JyNI3o267T999f1oPu7gFeShdt/G", reset_password_token: nil, reset_password_sent_at: nil, remember_created_at: nil, sign_in_count: 1, current_sign_in_at: "2016-08-14 19:05:29", last_sign_in_at: "2016-08-14 19:05:29", current_sign_in_ip: "94.215.220.66", last_sign_in_ip: "94.215.220.66", name: "Dion", role: "user", locale: nil}
])
Language.create!([
  {name: "Nederlands", abbreviation: "nl"},
  {name: "English", abbreviation: "en"}
])
LetterSet.create!([
  {name: "standaard", letter_amount_points: "{:A=>[6, 1], :B=>[2, 3], :C=>[2, 5], :D=>[5, 1], :E=>[18, 1], :F=>[2, 4], :G=>[3, 3], :H=>[2, 4], :I=>[4, 1], :J=>[2, 4], :K=>[3, 3], :L=>[3, 3], :M=>[3, 3], :N=>[10, 1], :O=>[6, 1], :P=>[2, 3], :Q=>[1, 10], :R=>[5, 2], :S=>[5, 2], :T=>[5, 2], :U=>[3, 4], :V=>[2, 4], :W=>[2, 5], :X=>[1, 8], :Y=>[1, 8], :Z=>[2, 4], :\"\"=>[2, 0]}"}
])
