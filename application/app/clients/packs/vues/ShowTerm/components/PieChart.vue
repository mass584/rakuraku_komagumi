<script>
import { Pie, mixins } from 'vue-chartjs';

export default {
  extends: Pie,
  mixins: [mixins.reactiveData],
  props: ['data', 'options'],
  mounted () {
    this.renderChart(this.data, this.options);
  },
  watch: {
    data: function() {
      this.renderChart(this.data, this.options);
    }
  }
}
</script>
