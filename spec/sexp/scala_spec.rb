require 'spec_helper'

describe Travis::Build::Script::Scala, :sexp do
  let(:data)   { PAYLOADS[:push].deep_clone }
  let(:script) { described_class.new(data) }
  subject      { script.sexp }

  it_behaves_like 'a build script sexp'
  it_behaves_like 'a jvm build sexp'

  it 'sets TRAVIS_SCALA_VERSION' do
    should include_sexp [:export, ['TRAVIS_SCALA_VERSION', '2.10.4'], echo: true]
  end

  it 'announces Scala 2.10.4' do
    should include_sexp [:echo, 'Using Scala 2.10.4']
  end

  let(:export_jvm_opts) { [:export, ['JVM_OPTS', '@/etc/sbt/jvmopts'], echo: true] }
  let(:export_sbt_opts) { [:export, ['SBT_OPTS', '@/etc/sbt/sbtopts'], echo: true] }

  describe 'if ./project directory or build.sbt file exists' do
    let(:sexp) { sexp_find(subject, [:if, '-d project || -f build.sbt']) }

    it "sets JVM_OPTS" do
      should include_sexp export_jvm_opts
    end

    it "sets SBT_OPTS" do
      should include_sexp export_sbt_opts
    end
  end

  describe 'script' do
    describe 'if ./project directory or build.sbt file exists' do
      let(:sexp) { sexp_find(sexp_filter(subject, [:if, '-d project || -f build.sbt'])[1], [:then]) }

      it "runs sbt with default arguments" do
        expect(sexp).to include_sexp [:cmd, 'sbt ++2.10.4 test', echo: true, timing: true]
      end

      it "runs sbt with additional arguments" do
        data["config"]["sbt_args"] = "-Dsbt.log.noformat=true"
        expect(sexp).to include_sexp [:cmd, 'sbt -Dsbt.log.noformat=true ++2.10.4 test', echo: true, timing: true]
      end
    end
  end
end
