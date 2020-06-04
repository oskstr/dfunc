# dfunc - Work in progress
 A reimplementation of datasektionen/dfunkt but with pure functions. 
 
 Motivation: Mostly a passion project  - no real need for this. I just like functional 
 programming languages and want to learn more about them.
 
## Plan
- Reimplement frontend in Elm
  - Should be more mobile friendly
  - Change some views - especially admin view and user lookup could use some better UX design
  - During first stage, pull data from old endpoints
  - Use login2 for auth like old app
  - Unit testing
- Reimplement backend/api in Haskell
  - Probably use PostgreSQL and [postgresql-typed](https://hackage.haskell.org/package/postgresql-typed) to get some of that lovely type-checking throughout everything.
  - Have to do more research on frameworks, TBD. 
- CI/CD
  - Would like to figure out how to deploy with dokku like all other microservices in Datasektionen 
  - Preferably also use GitHub Actions or something similar to run test suite and then deploy automatically on push.
  - Write simple Slack-bot to provide updates on status from CI/CD, maybe just an AWS Lambda function if GitHub doesn't have it built in to Actions.
  
