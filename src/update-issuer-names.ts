import axios from 'axios'
import https from 'https'
import fs from 'fs'

export async function updateIssuerNames() {
  const axiosVault = axios.create({
    baseURL: process.env.VAULT_ADDR,
    httpsAgent: new https.Agent({
      ca: fs.readFileSync('/etc/ssl/certs/vault-ca.crt')
    })
  })

  const response = await axiosVault.get('/v1/auth/token/lookup-self')
  console.log('response.status', response.status)
  console.log('response.statusText', response.statusText)
  console.log('response.data', response.data)
}

updateIssuerNames().catch((err) => { console.error(err); process.exit(1) })
