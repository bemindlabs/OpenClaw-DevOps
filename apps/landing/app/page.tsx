import { Button } from "@/components/ui/button";
import { Card } from "@/components/ui/card";
import { ArrowRight, Server, Zap, Shield, Terminal, Database, Gauge, Cloud } from "lucide-react";

export default function HomePage() {
  return (
    <div className="min-h-screen bg-neutral-950">
      {/* Hero Section */}
      <section className="relative overflow-hidden border-b border-neutral-800">
        <div className="absolute inset-0 bg-[linear-gradient(to_right,#3f3f4610_1px,transparent_1px),linear-gradient(to_bottom,#3f3f4610_1px,transparent_1px)] bg-[size:4rem_4rem] [mask-image:radial-gradient(ellipse_80%_50%_at_50%_0%,#000_70%,transparent_110%)]" />
        <div className="absolute inset-0 bg-gradient-to-b from-primary-950/20 via-transparent to-transparent" />

        <div className="relative mx-auto max-w-7xl px-6 py-24 sm:py-32 lg:px-8">
          <div className="mx-auto max-w-3xl text-center">
            {/* Badge */}
            <div className="inline-flex items-center gap-2 rounded-full border border-primary-800/50 bg-primary-950/50 px-4 py-1.5 text-sm text-primary-400 backdrop-blur-sm mb-8">
              <span className="relative flex h-2 w-2">
                <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-primary-400 opacity-75"></span>
                <span className="relative inline-flex rounded-full h-2 w-2 bg-primary-500"></span>
              </span>
              Production-Ready DevOps Platform
            </div>

            <h1 className="text-5xl font-bold tracking-tight text-neutral-50 sm:text-7xl mb-6">
              OpenClaw
              <span className="block text-primary-500 mt-2">DevOps</span>
            </h1>

            <p className="mt-6 text-xl leading-8 text-neutral-300 max-w-2xl mx-auto">
              Complete DevOps infrastructure platform. Deploy, monitor, and manage your full-stack applications with enterprise-grade tools.
            </p>

            <div className="mt-10 flex items-center justify-center gap-x-6">
              <Button
                size="lg"
                className="bg-primary-600 hover:bg-primary-500 text-black font-semibold shadow-glow-md hover:shadow-glow-lg transition-all"
                asChild
              >
                <a href="https://github.com/bemindlabs/OpenClaw-DevOps" target="_blank" rel="noopener noreferrer">
                  Get Started
                  <ArrowRight className="ml-2 h-5 w-5" />
                </a>
              </Button>
              <Button
                size="lg"
                variant="outline"
                className="border-neutral-700 text-neutral-200 hover:bg-neutral-900 hover:text-primary-400 hover:border-primary-800"
                asChild
              >
                <a href="https://github.com/bemindlabs/OpenClaw-DevOps/wiki" target="_blank" rel="noopener noreferrer">
                  <Terminal className="mr-2 h-5 w-5" />
                  View Documentation
                </a>
              </Button>
            </div>

            {/* Tech Stack Badges */}
            <div className="mt-16 flex flex-wrap items-center justify-center gap-4 text-sm text-neutral-500">
              <span>Powered by:</span>
              <div className="flex flex-wrap gap-3">
                <span className="px-3 py-1 rounded-md bg-neutral-900 border border-neutral-800 text-neutral-400">Docker</span>
                <span className="px-3 py-1 rounded-md bg-neutral-900 border border-neutral-800 text-neutral-400">Kubernetes</span>
                <span className="px-3 py-1 rounded-md bg-neutral-900 border border-neutral-800 text-neutral-400">MongoDB</span>
                <span className="px-3 py-1 rounded-md bg-neutral-900 border border-neutral-800 text-neutral-400">PostgreSQL</span>
                <span className="px-3 py-1 rounded-md bg-neutral-900 border border-neutral-800 text-neutral-400">Redis</span>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Features Section */}
      <section className="py-24 sm:py-32">
        <div className="mx-auto max-w-7xl px-6 lg:px-8">
          <div className="mx-auto max-w-2xl text-center mb-16">
            <h2 className="text-base font-semibold text-primary-500 mb-2">
              Full Stack Platform
            </h2>
            <h3 className="text-4xl font-bold tracking-tight text-neutral-50 sm:text-5xl">
              Everything you need for DevOps
            </h3>
            <p className="mt-4 text-lg text-neutral-400">
              From infrastructure to monitoring, all the tools your team needs in one platform.
            </p>
          </div>

          <div className="mx-auto grid max-w-7xl grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-4">
            <Card className="bg-neutral-900 border-neutral-800 p-6 hover:border-primary-800 hover:bg-neutral-900/80 transition-all group">
              <div className="flex items-center justify-center w-12 h-12 bg-primary-950 rounded-lg mb-4 group-hover:shadow-glow-sm transition-shadow">
                <Server className="h-6 w-6 text-primary-500" />
              </div>
              <h3 className="text-lg font-semibold text-neutral-100 mb-2">
                Service Orchestration
              </h3>
              <p className="text-neutral-400 text-sm leading-relaxed">
                Manage multiple services with Docker Compose and Kubernetes support out of the box.
              </p>
            </Card>

            <Card className="bg-neutral-900 border-neutral-800 p-6 hover:border-primary-800 hover:bg-neutral-900/80 transition-all group">
              <div className="flex items-center justify-center w-12 h-12 bg-primary-950 rounded-lg mb-4 group-hover:shadow-glow-sm transition-shadow">
                <Database className="h-6 w-6 text-primary-500" />
              </div>
              <h3 className="text-lg font-semibold text-neutral-100 mb-2">
                Database Stack
              </h3>
              <p className="text-neutral-400 text-sm leading-relaxed">
                MongoDB, PostgreSQL, and Redis pre-configured with automatic backups and replication.
              </p>
            </Card>

            <Card className="bg-neutral-900 border-neutral-800 p-6 hover:border-primary-800 hover:bg-neutral-900/80 transition-all group">
              <div className="flex items-center justify-center w-12 h-12 bg-primary-950 rounded-lg mb-4 group-hover:shadow-glow-sm transition-shadow">
                <Gauge className="h-6 w-6 text-primary-500" />
              </div>
              <h3 className="text-lg font-semibold text-neutral-100 mb-2">
                Real-time Monitoring
              </h3>
              <p className="text-neutral-400 text-sm leading-relaxed">
                Prometheus and Grafana dashboards with custom metrics and alerting.
              </p>
            </Card>

            <Card className="bg-neutral-900 border-neutral-800 p-6 hover:border-primary-800 hover:bg-neutral-900/80 transition-all group">
              <div className="flex items-center justify-center w-12 h-12 bg-primary-950 rounded-lg mb-4 group-hover:shadow-glow-sm transition-shadow">
                <Shield className="h-6 w-6 text-primary-500" />
              </div>
              <h3 className="text-lg font-semibold text-neutral-100 mb-2">
                Security First
              </h3>
              <p className="text-neutral-400 text-sm leading-relaxed">
                SSL/TLS, authentication, rate limiting, and firewall configuration included.
              </p>
            </Card>
          </div>
        </div>
      </section>

      {/* Stack Section */}
      <section className="py-24 bg-neutral-900/50 border-y border-neutral-800">
        <div className="mx-auto max-w-7xl px-6 lg:px-8">
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-12 items-center">
            <div>
              <h2 className="text-base font-semibold text-primary-500 mb-2">
                Complete Infrastructure
              </h2>
              <h3 className="text-3xl font-bold text-neutral-50 mb-6">
                Modern DevOps stack, ready to deploy
              </h3>
              <div className="space-y-4">
                <div className="flex items-start gap-3">
                  <div className="flex-shrink-0 w-8 h-8 rounded-lg bg-primary-950 flex items-center justify-center">
                    <Zap className="h-4 w-4 text-primary-500" />
                  </div>
                  <div>
                    <h4 className="text-neutral-100 font-medium mb-1">Fast Deployment</h4>
                    <p className="text-sm text-neutral-400">One-command deployment with automated setup scripts</p>
                  </div>
                </div>
                <div className="flex items-start gap-3">
                  <div className="flex-shrink-0 w-8 h-8 rounded-lg bg-primary-950 flex items-center justify-center">
                    <Cloud className="h-4 w-4 text-primary-500" />
                  </div>
                  <div>
                    <h4 className="text-neutral-100 font-medium mb-1">Cloud Native</h4>
                    <p className="text-sm text-neutral-400">Optimized for GCP, AWS, Azure, and on-premise deployments</p>
                  </div>
                </div>
                <div className="flex items-start gap-3">
                  <div className="flex-shrink-0 w-8 h-8 rounded-lg bg-primary-950 flex items-center justify-center">
                    <Terminal className="h-4 w-4 text-primary-500" />
                  </div>
                  <div>
                    <h4 className="text-neutral-100 font-medium mb-1">Developer Friendly</h4>
                    <p className="text-sm text-neutral-400">Comprehensive CLI tools and extensive documentation</p>
                  </div>
                </div>
              </div>
            </div>

            <div className="relative">
              <div className="absolute -inset-4 bg-gradient-to-r from-primary-600/20 to-accent-600/20 rounded-2xl blur-2xl"></div>
              <Card className="relative bg-neutral-950 border-neutral-800 p-6">
                <pre className="text-sm text-neutral-300 overflow-x-auto">
                  <code className="text-primary-400"># Start the platform</code>
                  {'\n'}<code className="text-neutral-500">$</code> <code className="text-neutral-200">./start-all.sh</code>
                  {'\n\n'}<code className="text-accent-400">✓</code> <code className="text-neutral-400">Nginx running on port 80</code>
                  {'\n'}<code className="text-accent-400">✓</code> <code className="text-neutral-400">Landing page on port 3000</code>
                  {'\n'}<code className="text-accent-400">✓</code> <code className="text-neutral-400">Gateway on port 18789</code>
                  {'\n'}<code className="text-accent-400">✓</code> <code className="text-neutral-400">MongoDB on port 27017</code>
                  {'\n'}<code className="text-accent-400">✓</code> <code className="text-neutral-400">PostgreSQL on port 5432</code>
                  {'\n'}<code className="text-accent-400">✓</code> <code className="text-neutral-400">Redis on port 6379</code>
                  {'\n\n'}<code className="text-primary-500">🚀 All services healthy!</code>
                </pre>
              </Card>
            </div>
          </div>
        </div>
      </section>

      {/* CTA Section */}
      <section className="py-24">
        <div className="mx-auto max-w-7xl px-6 lg:px-8">
          <Card className="relative overflow-hidden bg-gradient-to-br from-primary-950 via-neutral-900 to-neutral-950 border-primary-900/50 p-12 text-center">
            <div className="absolute inset-0 bg-[linear-gradient(to_right,#16a34a10_1px,transparent_1px),linear-gradient(to_bottom,#16a34a10_1px,transparent_1px)] bg-[size:4rem_4rem]" />
            <div className="relative">
              <h2 className="text-4xl font-bold tracking-tight text-neutral-50 sm:text-5xl mb-4">
                Ready to streamline your DevOps?
              </h2>
              <p className="text-lg text-neutral-300 mb-8 max-w-2xl mx-auto">
                Join teams using OpenClaw to manage their infrastructure efficiently.
              </p>
              <div className="flex items-center justify-center gap-4 flex-wrap">
                <Button
                  size="lg"
                  className="bg-primary-600 hover:bg-primary-500 text-black font-semibold shadow-glow-md hover:shadow-glow-lg"
                  asChild
                >
                  <a href="https://github.com/bemindlabs/OpenClaw-DevOps" target="_blank" rel="noopener noreferrer">
                    Deploy Now
                    <ArrowRight className="ml-2 h-5 w-5" />
                  </a>
                </Button>
                <Button
                  size="lg"
                  variant="outline"
                  className="border-primary-700 text-neutral-200 hover:bg-primary-950 hover:text-primary-400"
                  asChild
                >
                  <a href="https://github.com/bemindlabs/OpenClaw-DevOps" target="_blank" rel="noopener noreferrer">
                    <Terminal className="mr-2 h-5 w-5" />
                    View on GitHub
                  </a>
                </Button>
              </div>
            </div>
          </Card>
        </div>
      </section>

      {/* Footer */}
      <footer className="border-t border-neutral-800 bg-neutral-900/30">
        <div className="mx-auto max-w-7xl px-6 py-12 lg:px-8">
          <div className="grid grid-cols-1 md:grid-cols-4 gap-8 mb-8">
            <div className="col-span-1 md:col-span-2">
              <h3 className="text-lg font-bold text-neutral-50 mb-2">OpenClaw DevOps</h3>
              <p className="text-sm text-neutral-400 max-w-md">
                Open-source DevOps platform for modern infrastructure management.
              </p>
            </div>
            <div>
              <h4 className="text-sm font-semibold text-neutral-300 mb-3">Platform</h4>
              <ul className="space-y-2 text-sm text-neutral-500">
                <li><a href="#" className="hover:text-primary-500 transition-colors">Documentation</a></li>
                <li><a href="#" className="hover:text-primary-500 transition-colors">GitHub</a></li>
                <li><a href="#" className="hover:text-primary-500 transition-colors">Community</a></li>
              </ul>
            </div>
            <div>
              <h4 className="text-sm font-semibold text-neutral-300 mb-3">Resources</h4>
              <ul className="space-y-2 text-sm text-neutral-500">
                <li><a href="#" className="hover:text-primary-500 transition-colors">Quick Start</a></li>
                <li><a href="#" className="hover:text-primary-500 transition-colors">Architecture</a></li>
                <li><a href="#" className="hover:text-primary-500 transition-colors">Support</a></li>
              </ul>
            </div>
          </div>
          <div className="border-t border-neutral-800 pt-8">
            <p className="text-center text-sm text-neutral-500">
              © 2026 OpenClaw DevOps. Open source under MIT License.
            </p>
          </div>
        </div>
      </footer>
    </div>
  );
}
