import { useState, useEffect } from 'react'
import { useNavigate } from 'react-router-dom'
import axios, { AxiosError } from 'axios'
import ThemeInput from './ThemeInput.tsx'
import LoadingStatus from './LoadingStatus.tsx'
import { API_BASE_URL } from '../util.ts'
import type { JobResponse, JobStatus } from '../types.ts'

function StoryGenerator() {
  const navigate = useNavigate()
  const [theme, setTheme] = useState('')
  const [jobId, setJobId] = useState<string | null>(null)
  const [jobStatus, setJobStatus] = useState<JobStatus | null>(null)
  const [error, setError] = useState<string | null>(null)
  const [loading, setLoading] = useState(false)

  useEffect(() => {
    let pollInterval: ReturnType<typeof setInterval> | undefined

    if (jobId && (jobStatus === 'pending' || jobStatus === 'processing')) {
      pollInterval = setInterval(() => {
        pollJobStatus(jobId)
      }, 3000)
    }

    return () => {
      if (pollInterval) {
        clearInterval(pollInterval)
      }
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [jobId, jobStatus])

  const generateStory = async (theme: string) => {
    setLoading(true)
    setError(null)
    setTheme(theme)

    try {
      const response = await axios.post<JobResponse>(
        `${API_BASE_URL}/stories/create`,
        { theme },
      )
      const { job_id, status } = response.data
      setJobId(job_id)
      setJobStatus(status)

      pollJobStatus(job_id)
    } catch (e) {
      setLoading(false)
      const err = e as Error
      setError(`Failed to generate story: ${err.message}`)
    }
  }

  const pollJobStatus = async (id: string) => {
    try {
      const response = await axios.get<JobResponse>(`${API_BASE_URL}/jobs/${id}`)
      const { status, story_id, error: jobError } = response.data
      setJobStatus(status)

      if (status === 'completed' && story_id) {
        fetchStory(story_id)
      } else if (status === 'failed' || jobError) {
        setError(jobError || 'Failed to generate story')
        setLoading(false)
      }
    } catch (e) {
      const err = e as AxiosError
      if (err.response?.status !== 404) {
        setError(`Failed to check story status: ${err.message}`)
        setLoading(false)
      }
    }
  }

  const fetchStory = (id: number) => {
    setLoading(false)
    setJobStatus('completed')
    navigate(`/story/${id}`)
  }

  const reset = () => {
    setJobId(null)
    setJobStatus(null)
    setError(null)
    setTheme('')
    setLoading(false)
  }

  return (
    <div className="story-generator">
      {error && (
        <div className="error-message">
          <p>{error}</p>
          <button onClick={reset}>Try Again</button>
        </div>
      )}

      {!jobId && !error && !loading && <ThemeInput onSubmit={generateStory} />}

      {loading && <LoadingStatus theme={theme} />}
    </div>
  )
}

export default StoryGenerator
