if command -v op &> /dev/null
  alias yarn='op run --no-masking -- yarn'
  alias pnpm='op run --no-masking -- pnpm'

  alias bi='op run --no-masking -- bundle install'
  alias bu='op run --no-masking -- bundle update'
end
