export interface StoryOption {
  text: string
  node_id: number | null
}

export interface StoryNode {
  id: number
  content: string
  is_ending: boolean
  is_winning_ending: boolean
  options: StoryOption[]
}

export interface Story {
  id: number
  title: string
  session_id: string | null
  created_at: string
  root_node: StoryNode
  all_nodes: Record<string, StoryNode>
}

export type JobStatus = 'pending' | 'processing' | 'completed' | 'failed'

export interface JobResponse {
  job_id: string
  status: JobStatus
  story_id?: number | null
  error?: string | null
}
