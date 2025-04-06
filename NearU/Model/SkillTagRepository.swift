//
//  TechTagRepository.swift
//  NearU
//
//  Created by 高橋和 on 2025/03/23.
//

import Foundation

struct SkillTagRepository {
    static let skillTags: [String: [String]] = [
        "言語": ["Swift", "Kotlin", "JavaScript", "Python", "Go", "Java", "Ruby", "PHP", "TypeScript", "C", "C++", "C#", "HTML", "CSS", "Rust", "Dart", "Elixir"],
        "フレームワーク": ["React", "Next.js", "Vue", "Nuxt.js", "Angular", "Node.js", "Django", "Flask", "Laravel", "CakePHP", "Flutter", "Rails", "Remix", "Tailwind CSS", "Spring"],
        "データベース": ["MySQL", "PostgreSQL", "MongoDB", "Redis", "MariaDB", "DynamoDB"],
        "その他": ["AWS", "GCP", "Azure", "Cloudflare", "Vercel", "Firebase", "Supabase", "Terraform", "Unity", "Blender", "Docker", "ROS"],
    ]
    
    static let displayOrder: [String] = ["言語", "フレームワーク", "データベース", "その他"]
    
    static let iconMapping: [String: String] = [
        // 言語
        "JavaScript": "JavaScript",
        "Python": "Python",
        "Java": "Java",
        "Ruby": "Ruby",
        "Swift": "Swift",
        "PHP": "PHP",
        "TypeScript": "TypeScript",
        "Go": "Go",
        "C": "C",
        "C++": "C-plus",
        "Kotlin": "Kotlin",
        "C#": "C-sharp",
        "HTML": "HTML",
        "CSS": "CSS",
        "Rust": "Rust",
        "Dart": "Dart",
        "Elixir": "Elixir",
        // フレームワーク
        "React": "React",
        "Next.js": "Next-js",
        "Vue": "Vue",
        "Nuxt.js": "Nuxt-js",
        "Angular": "Angular",
        "Node.js": "Node-js",
        "Django": "Django",
        "Flask": "Flask",
        "Laravel": "Laravel",
        "CakePHP": "CakePHP",
        "Flutter": "Flutter",
        "Rails": "Rails",
        "Remix": "Remix",
        "Tailwind CSS": "Tailwind-CSS",
        "Spring": "Spring",
        // データベース
        "MySQL": "MySQL",
        "PostgreSQL": "PostgreSQL",
        "MongoDB": "MongoDB",
        "Redis": "Redis",
        "MariaDB": "MariaDB",
        "DynamoDB": "DynamoDB",
        // その他
        "AWS": "AWS",
        "GCP": "GCP",
        "Azure": "Azure",
        "Cloudflare": "Cloudflare",
        "Vercel": "Vercel",
        "Firebase": "Firebase",
        "Supabase": "Supabase",
        "Terraform": "Terraform",
        "Unity": "Unity",
        "Blender": "Blender",
        "Docker": "Docker",
        "ROS": "ROS"
    ]
    
}
